/*
 * Copyright (c) 2025  Valentin David
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * Extended with path-keyed component manifest support for chunkah
 * integration (user.component / user.update-interval xattrs).
 *
 * Additional env vars:
 *   FAKECAP_MANIFEST      path to TSV manifest file to serve component
 *                         xattrs from (getxattr intercept, for LD_PRELOAD
 *                         use with chunkah once it uses libc for xattr reads)
 *   FAKECAP_STRIP_PREFIX  prefix stripped from absolute paths before
 *                         manifest lookup (e.g. the rootfs mount point)
 *   FAKECAP_MANIFEST_OUT  if set, append captured user.component setxattr
 *                         calls to this file (for BST build-time capture)
 *
 * Manifest format (TSV, one entry per line):
 *   /usr/bin/foo\tgnome-shell\tweekly
 *   /usr/lib/bar.so\tglib\tweekly
 * Lines starting with '#' are comments.
 */

#define _GNU_SOURCE

#include <dirent.h>
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/capability.h>
#include <sys/stat.h>
#include <sys/sysmacros.h>
#include <sys/xattr.h>
#include <unistd.h>

/* ── Original fakecap capability handling ──────────────────────────── */

static
int handle_cap(const char* name) {
  if (strcmp(name, "security.capability") == 0) {
    return 1;
  }
  if (strncmp(name, "user.validatefs.", 16) == 0) {
    return 1;
  }
  return 0;
}

static
int open_metadata(struct stat *st, const char* name, int flags, mode_t mode) {
  char *path = NULL;
  int r, fd;

  r = asprintf(&path,
               "%s/%u-%u-%lu-%s",
               getenv("FAKECAP_DB"),
               major(st->st_dev), minor(st->st_dev),
               st->st_ino,
               name);
  if (r < 0) {
    if (path != NULL)
      free(path);
    return r;
  }

  fd = open(path, flags, mode);
  free(path);
  return fd;
}

static
ssize_t readxattr(struct stat *st, const char* name, void *value, size_t size) {
  int db_fd;
  struct stat db_st;
  char overflow;
  ssize_t rsize;

  db_fd = open_metadata(st, name, O_RDONLY, 0);
  if (db_fd < 0) {
    errno = ENODATA;
    return -1;
  }

  if (fstat(db_fd, &db_st) != 0) {
    close(db_fd);
    errno = ENODATA;
    return -1;
  }

  if (size == 0) {
    close(db_fd);
    return db_st.st_size;
  }

  if (db_st.st_size > (ssize_t)size) {
    close(db_fd);
    errno = ERANGE;
    return -1;
  }

  rsize = read(db_fd, value, size);
  if (rsize != db_st.st_size) {
    close(db_fd);
    errno = ENODATA;
    return -1;
  }

  /* check there is no overflow */
  if (read(db_fd, &overflow, 1) != 0) {
    close(db_fd);
    errno = ENODATA;
    return -1;
  }

  close(db_fd);
  return rsize;
}

static
ssize_t writexattr(struct stat *st, const char* name, const void *value, size_t size, int flags) {
  int db_fd;

  if (flags & XATTR_CREATE) {
    db_fd = open_metadata(st, name, O_WRONLY | O_CREAT | O_EXCL, 0666);
  } else if (flags & XATTR_REPLACE) {
    db_fd = open_metadata(st, name, O_WRONLY | O_CREAT, 0666);
  } else {
    db_fd = open_metadata(st, name, O_WRONLY | O_CREAT | O_TRUNC, 0666);
  }

  if (db_fd < 0) {
    return db_fd;
  }

  if (write(db_fd, value, size) != (ssize_t)size) {
    close(db_fd);
    return -1;
  }

  close(db_fd);
  return size;
}

static
ssize_t list_metadata(struct stat *st, char *list, size_t size,
                      const char *existing_list, size_t existing_size) {
  DIR *db;
  struct dirent *ent;
  char *prefix = NULL;
  size_t prefix_len;
  ssize_t written = 0;

  if (asprintf(&prefix,
               "%u-%u-%lu-",
               major(st->st_dev), minor(st->st_dev),
               st->st_ino) < 0) {
    return 0;
  }
  prefix_len = strlen(prefix);

  db = opendir(getenv("FAKECAP_DB"));
  if (db == NULL) {
    free(prefix);
    return 0;
  }

  while ((ent = readdir(db)) != NULL) {
    size_t name_len;
    if (strncmp(ent->d_name, prefix, prefix_len) != 0) {
      continue;
    }
    if (existing_list != NULL) {
      size_t offset = 0;
      int found = 0;
      while (offset < existing_size) {
        size_t entry_len = strlen(existing_list + offset);
        if (strcmp(existing_list + offset, ent->d_name + prefix_len) == 0) {
          found = 1;
          break;
        }
        offset += entry_len + 1;
      }
      if (found) {
        continue;
      }
    }
    name_len = strlen(ent->d_name + prefix_len);
    if (list != NULL) {
      if (size <= name_len) {
        closedir(db);
        free(prefix);
        errno = ERANGE;
        return -1;
      }
      strcpy(list, ent->d_name + prefix_len);
      list += name_len + 1;
      size -= name_len + 1;
    }
    written += name_len + 1;
  }

  closedir(db);
  free(prefix);

  return written;
}

/* ── Component manifest (path-keyed, for user.component xattrs) ───── */

typedef struct {
    const char *path;
    const char *component;
    const char *interval;
} ManifestEntry;

static ManifestEntry  *manifest      = NULL;
static size_t          manifest_len  = 0;
static char           *manifest_buf  = NULL;

static int entry_cmp(const void *a, const void *b) {
    return strcmp(((const ManifestEntry *)a)->path,
                  ((const ManifestEntry *)b)->path);
}

__attribute__((constructor))
static void manifest_load(void) {
    const char *path = getenv("FAKECAP_MANIFEST");
    if (!path || !*path)
        return;

    FILE *f = fopen(path, "r");
    if (!f)
        return;

    /* Read entire file into buffer */
    fseek(f, 0, SEEK_END);
    long fsz = ftell(f);
    rewind(f);
    manifest_buf = malloc(fsz + 1);
    if (!manifest_buf) { fclose(f); return; }
    fread(manifest_buf, 1, fsz, f);
    manifest_buf[fsz] = '\0';
    fclose(f);

    /* Count non-comment lines */
    size_t cap = 0;
    for (char *p = manifest_buf; *p; p++)
        if (*p == '\n') cap++;

    manifest = malloc(cap * sizeof(*manifest));
    if (!manifest) return;

    char *line = manifest_buf;
    manifest_len = 0;
    while (*line) {
        char *nl = strchr(line, '\n');
        if (nl) *nl = '\0';

        if (*line && *line != '#') {
            char *tab1 = strchr(line, '\t');
            if (tab1) {
                *tab1 = '\0';
                char *tab2 = strchr(tab1 + 1, '\t');
                manifest[manifest_len].path      = line;
                manifest[manifest_len].component = tab1 + 1;
                manifest[manifest_len].interval  = tab2 ? tab2 + 1 : "weekly";
                if (tab2) *tab2 = '\0';
                manifest_len++;
            }
        }

        line = nl ? nl + 1 : line + strlen(line);
    }

    qsort(manifest, manifest_len, sizeof(*manifest), entry_cmp);
}

/* Strip FAKECAP_STRIP_PREFIX from path. */
static const char *strip_prefix(const char *path) {
    const char *pfx = getenv("FAKECAP_STRIP_PREFIX");
    if (!pfx || !*pfx) return path;
    size_t n = strlen(pfx);
    if (strncmp(path, pfx, n) == 0) {
        const char *rest = path + n;
        if (*rest == '/' || *rest == '\0') return rest;
    }
    return path;
}

static const ManifestEntry *manifest_lookup(const char *path) {
    if (!manifest || manifest_len == 0) return NULL;
    const char *rel = strip_prefix(path);
    ManifestEntry key = { .path = rel };
    return bsearch(&key, manifest, manifest_len, sizeof(*manifest), entry_cmp);
}

/* Resolve fd to absolute path via /proc. */
static char *fd_to_path(int fd) {
    char proc[64], *buf = malloc(PATH_MAX);
    if (!buf) return NULL;
    snprintf(proc, sizeof(proc), "/proc/self/fd/%d", fd);
    ssize_t n = readlink(proc, buf, PATH_MAX - 1);
    if (n < 0) { free(buf); return NULL; }
    buf[n] = '\0';
    return buf;
}

static int handle_component(const char *name) {
    return strcmp(name, "user.component") == 0 ||
           strcmp(name, "user.update-interval") == 0;
}

/* Serve a component xattr from the manifest. */
static ssize_t manifest_getxattr(const char *path, const char *name,
                                  void *value, size_t size) {
    const ManifestEntry *e = manifest_lookup(path);
    if (!e) { errno = ENODATA; return -1; }

    const char *val;
    if (strcmp(name, "user.component") == 0)
        val = e->component;
    else if (strcmp(name, "user.update-interval") == 0)
        val = e->interval;
    else { errno = ENODATA; return -1; }

    size_t vlen = strlen(val);
    if (size == 0) return (ssize_t)vlen;
    if (size < vlen) { errno = ERANGE; return -1; }
    memcpy(value, val, vlen);
    return (ssize_t)vlen;
}

/*
 * Append a captured component xattr write to FAKECAP_MANIFEST_OUT.
 * Used when fakecap is LD_PRELOAD'd during BST install steps that call
 * setfattr explicitly, so the manifest accumulates across elements.
 */
static void manifest_capture(const char *path, const char *name,
                               const void *value, size_t size) {
    const char *out = getenv("FAKECAP_MANIFEST_OUT");
    if (!out || !*out) return;
    if (!handle_component(name)) return;

    /* Only capture user.component lines (interval handled separately) */
    if (strcmp(name, "user.component") != 0) return;

    const char *rel = strip_prefix(path);
    FILE *f = fopen(out, "a");
    if (!f) return;
    fprintf(f, "%s\t%.*s\tweekly\n", rel, (int)size, (char *)value);
    fclose(f);
}

/* ── xattr intercepts ──────────────────────────────────────────────── */

ssize_t getxattr(const char *path, const char *name,
                 void *value, size_t size) {
  ssize_t (*next)(const char *, const char *, void *, size_t);
  ssize_t next_ret;
  struct stat st;

  next = (ssize_t (*)(const char *, const char *, void *, size_t))dlsym(RTLD_NEXT, "getxattr");

  if (handle_component(name))
    return manifest_getxattr(path, name, value, size);

  if (!handle_cap(name)) {
    return next(path, name, value, size);
  }
  if (stat(path, &st) != 0) {
    return next(path, name, value, size);
  }

  next_ret = readxattr(&st, name, value, size);
  if (next_ret < 0) {
    return next(path, name, value, size);
  }
  return next_ret;
}

ssize_t lgetxattr(const char *path, const char *name,
                  void *value, size_t size) {
  ssize_t (*next)(const char *, const char *, void *, size_t);
  ssize_t next_ret;
  struct stat st;

  next = (ssize_t (*)(const char *, const char *, void *, size_t))dlsym(RTLD_NEXT, "lgetxattr");

  if (handle_component(name))
    return manifest_getxattr(path, name, value, size);

  if (!handle_cap(name)) {
    return next(path, name, value, size);
  }
  if (lstat(path, &st) != 0) {
    return next(path, name, value, size);
  }

  next_ret = readxattr(&st, name, value, size);
  if (next_ret < 0) {
    return next(path, name, value, size);
  }
  return next_ret;
}

ssize_t fgetxattr(int fd, const char *name,
                  void *value, size_t size) {
  ssize_t (*next)(int, const char *, void *, size_t);
  ssize_t next_ret;
  struct stat st;

  next = (ssize_t (*)(int, const char *, void *, size_t))dlsym(RTLD_NEXT, "fgetxattr");

  if (handle_component(name)) {
    char *path = fd_to_path(fd);
    if (!path) { errno = ENODATA; return -1; }
    ssize_t r = manifest_getxattr(path, name, value, size);
    free(path);
    return r;
  }

  if (!handle_cap(name)) {
    return next(fd, name, value, size);
  }
  if (fstat(fd, &st) != 0) {
    return next(fd, name, value, size);
  }

  next_ret = readxattr(&st, name, value, size);
  if (next_ret < 0) {
    return next(fd, name, value, size);
  }
  return next_ret;
}

int setxattr(const char *path, const char *name,
             const void *value, size_t size, int flags) {
  int (*next)(const char *path, const char *name,
             const void *value, size_t size, int flags);
  struct stat st;
  int wsize;

  next = (int (*)(const char *path, const char *name,
                  const void *value, size_t size, int flags))dlsym(RTLD_NEXT, "setxattr");

  if (handle_component(name)) {
    manifest_capture(path, name, value, size);
    return 0;
  }
  if (!handle_cap(name)) {
    return next(path, name, value, size, flags);
  }
  if (stat(path, &st) != 0) {
    return next(path, name, value, size, flags);
  }

  wsize = writexattr(&st, name, value, size, flags);
  if (wsize < 0) {
    return next(path, name, value, size, flags);
  }
  return 0;
}

int lsetxattr(const char *path, const char *name,
             const void *value, size_t size, int flags) {
  int (*next)(const char *path, const char *name,
             const void *value, size_t size, int flags);
  struct stat st;
  int wsize;

  next = (int (*)(const char *path, const char *name,
                  const void *value, size_t size, int flags))dlsym(RTLD_NEXT, "lsetxattr");

  if (handle_component(name)) {
    manifest_capture(path, name, value, size);
    return 0;
  }
  if (!handle_cap(name)) {
    return next(path, name, value, size, flags);
  }
  if (lstat(path, &st) != 0) {
    return next(path, name, value, size, flags);
  }

  wsize = writexattr(&st, name, value, size, flags);
  if (wsize < 0) {
    return next(path, name, value, size, flags);
  }
  return 0;
}

int fsetxattr(int fd, const char *name,
              const void *value, size_t size, int flags) {
  int (*next)(int fd, const char *name,
              const void *value, size_t size, int flags);
  struct stat st;
  int wsize;

  next = (int (*)(int fd, const char *name,
                  const void *value, size_t size, int flags))dlsym(RTLD_NEXT, "fsetxattr");

  if (handle_component(name)) {
    char *path = fd_to_path(fd);
    if (path) { manifest_capture(path, name, value, size); free(path); }
    return 0;
  }
  if (!handle_cap(name)) {
    return next(fd, name, value, size, flags);
  }
  if (fstat(fd, &st) != 0) {
    return next(fd, name, value, size, flags);
  }

  wsize = writexattr(&st, name, value, size, flags);
  if (wsize < 0) {
    return next(fd, name, value, size, flags);
  }
  return 0;
}

int cap_set_flag(cap_t cap_d, cap_flag_t set,
 int no_values, const cap_value_t *array_values,
 cap_flag_value_t raise) {
  int (*next)(cap_t, cap_flag_t, int, const cap_value_t *,
              cap_flag_value_t);

  next = dlsym(RTLD_NEXT, "cap_set_flag");

  if (set == CAP_EFFECTIVE) {
    return 0;
  }
  return next(cap_d, set, no_values, array_values, raise);
}

ssize_t listxattr(const char *path, char *list, size_t size) {
  ssize_t (*next)(const char *, char *, size_t);
  ssize_t next_ret, more_ret;
  struct stat st;

  next = (ssize_t (*)(const char *, char *, size_t))dlsym(RTLD_NEXT, "listxattr");

  next_ret = next(path, list, size);
  if (next_ret < 0) {
    if (errno != ENOTSUP) {
      return next_ret;
    }
    next_ret = 0;
  }

  if (stat(path, &st) != 0) {
    return next_ret;
  }

  more_ret = list_metadata(&st, size?list + next_ret:NULL, size?size - next_ret:0, size?list:NULL, size?next_ret:0);

  return next_ret + more_ret;
}

ssize_t llistxattr(const char *path, char *list, size_t size) {
  ssize_t (*next)(const char *, char *, size_t);
  ssize_t next_ret, more_ret;
  struct stat st;

  next = (ssize_t (*)(const char *, char *, size_t))dlsym(RTLD_NEXT, "llistxattr");

  next_ret = next(path, list, size);
  if (next_ret < 0) {
    if (errno != ENOTSUP) {
      return next_ret;
    }
    next_ret = 0;
  }

  if (lstat(path, &st) != 0) {
    return next_ret;
  }

  more_ret = list_metadata(&st, size?list + next_ret:NULL, size?size - next_ret:0, size?list:NULL, size?next_ret:0);

  return next_ret + more_ret;
}

ssize_t flistxattr(int fd, char *list, size_t size) {
  ssize_t (*next)(int, char *, size_t);
  ssize_t next_ret, more_ret;
  struct stat st;

  next = (ssize_t (*)(int, char *, size_t))dlsym(RTLD_NEXT, "flistxattr");

  next_ret = next(fd, list, size);
  if (next_ret < 0) {
    if (errno != ENOTSUP) {
      return next_ret;
    }
    next_ret = 0;
  }

  if (fstat(fd, &st) != 0) {
    return next_ret;
  }

  more_ret = list_metadata(&st, size?list + next_ret:NULL, size?size - next_ret:0, size?list:NULL, size?next_ret:0);

  if ((more_ret >= 0) && (size != 0) && (list != 0)) {
    for (size_t i = 0; i < more_ret;) {
      i += strlen(list + i) + 1;
    }
  }

  return next_ret + more_ret;
}
