kind: meson

sources:
- kind: git_repo
  url: gnome:gnome-epub-thumbnailer.git
  track: "1.8"
  ref: 1.8

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- freedesktop-sdk.bst:components/libarchive.bst
- freedesktop-sdk.bst:components/libxml2.bst
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- gnome-build-meta.bst:sdk/gdk-pixbuf.bst
- gnome-build-meta.bst:sdk/glib.bst
