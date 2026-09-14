kind: meson

sources:
- kind: tar
  url: swaync_releases:v0.12.6/swaync-0.12.6.tar.gz
  ref: 0c844eb5c9524f924495bd4145e5db575096de36f3ec87fb37e4c1ed6eacb897

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/pkg-config.bst

depends:
- gnome-build-meta.bst:sdk/gtk.bst
- gnome-build-meta.bst:sdk/libadwaita.bst
- bluefin/gtk4-layer-shell.bst
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

config:
  install-commands:
  - meson install --destdir "%{install-root}"