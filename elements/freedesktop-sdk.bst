kind: junction

sources:
- kind: git_repo
  url: https://gitlab.com/freedesktop-sdk/freedesktop-sdk.git
  track: freedesktop-sdk-26.08*
  ref: freedesktop-sdk-26.08.0-0-gdb97cce32cecadc7a3e98f06d557ebfa6ba9ad46
- kind: patch_queue
  path: patches/freedesktop-sdk

config:
  overrides:
    components/linux.bst: core/linux-mainline.bst
    components/glib.bst: gnome-build-meta.bst:sdk/glib.bst
    components/at-spi2-core.bst: gnome-build-meta.bst:sdk/at-spi2-core.bst
    components/cairo.bst: gnome-build-meta.bst:sdk/cairo.bst
    components/gdk-pixbuf.bst: gnome-build-meta.bst:sdk/gdk-pixbuf.bst
    components/gobject-introspection.bst: gnome-build-meta.bst:sdk/gobject-introspection.bst
    components/graphene.bst: gnome-build-meta.bst:sdk/graphene.bst
    components/json-glib.bst: gnome-build-meta.bst:sdk/json-glib.bst
    components/libglycin.bst: gnome-build-meta.bst:sdk/libglycin.bst
    components/librsvg.bst: gnome-build-meta.bst:sdk/librsvg.bst
    components/pango.bst: gnome-build-meta.bst:sdk/pango.bst
    components/vala.bst: gnome-build-meta.bst:sdk/vala.bst
    (?):
    - gaming == true:
        components/linux.bst: core/linux-ogc.bst
