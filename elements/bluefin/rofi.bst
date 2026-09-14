kind: meson

sources:
- kind: tar
  url: rofi_releases:2.0.0/rofi-2.0.0.tar.gz
  ref: f81659b175306ff487e35d88d6b36128e85a793bfb56b64fa22c62eb54c4abd0

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:components/glib.bst
- freedesktop-sdk.bst:components/pango.bst
- freedesktop-sdk.bst:components/cairo.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

config:
  install-commands:
  - meson install --destdir "%{install-root}"