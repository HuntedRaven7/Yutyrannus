kind: meson

sources:
- kind: tar
  url: mako_releases:v1.11.0/mako-1.11.0.tar.gz
  ref: e97eb5bd0dc6a9159019949f48b3db4e8781b56bd6377bd65827e1cb440a7def

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/pkg-config.bst

depends:
- freedesktop-sdk.bst:components/wayland.bst
- freedesktop-sdk.bst:components/wayland-protocols.bst
- freedesktop-sdk.bst:components/cairo.bst
- freedesktop-sdk.bst:components/pango.bst
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

config:
  install-commands:
  - meson install --destdir "%{install-root}"
