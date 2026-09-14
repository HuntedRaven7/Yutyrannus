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
    (?):
    - gaming == true:
        components/linux.bst: core/linux-ogc.bst
