kind: meson

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
- gnome-build-meta.bst:sdk/gtk.bst
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: tar
  url: github_files:wmww/gtk4-layer-shell/archive/refs/tags/v1.3.0.tar.gz
  ref: 1ebb01ab14e98afd1727f68f64981c37bd23305b1f131f5667c02b94cf593192

variables:
  meson-local: >-
    -Dexamples=false
    -Dintrospection=false
    -Dvapi=false
