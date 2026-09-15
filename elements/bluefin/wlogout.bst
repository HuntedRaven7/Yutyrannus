kind: meson

sources:
- kind: tar
  url: wlogout_releases:1.2.1/wlogout.tar.gz
  ref: 543a6e9abb8609863eac0460c37226b070bc070763115c0a85604fecb87fe0bb

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/pkg-config.bst

depends:
- gnome-build-meta.bst:sdk/gtk.bst
- bluefin/gtk4-layer-shell.bst
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

config:
  install-commands:
  - meson install --destdir "%{install-root}"