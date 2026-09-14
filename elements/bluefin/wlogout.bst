kind: meson

sources:
- kind: tar
  url: wlogout_releases:v1.2.1/wlogout-1.2.1.tar.gz
  ref: ceb64ada0cd16d7a2603f65dd5e1c4ab15837dc84ff1541de10d3f49637be243

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