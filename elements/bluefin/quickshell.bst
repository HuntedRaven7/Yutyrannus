kind: meson

sources:
- kind: git_repo
  url: github:quickshell-mirror/quickshell.git
  track: "[0-9]*.[0-9]*.[0-9]*"
  ref: 0.3.1

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/pkg-config.bst

depends:
- qt6/qt6base.bst
- qt6/qt6declarative.bst
- qt6/qt6svg.bst
- qt6/qt6wayland.bst
- freedesktop-sdk.bst:components/wayland.bst
- freedesktop-sdk.bst:components/wayland-protocols.bst
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

config:
  install-commands:
  - meson install --destdir "%{install-root}"