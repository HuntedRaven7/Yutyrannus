kind: meson

sources:
- kind: git_repo
  url: github:GrimAnticheat/Grim.git
  track: "v[0-9]*.[0-9]*.[0-9]*"
  ref: v2.3.73

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:components/wayland.bst
- freedesktop-sdk.bst:components/wayland-protocols.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

config:
  install-commands:
  - meson install --destdir "%{install-root}"