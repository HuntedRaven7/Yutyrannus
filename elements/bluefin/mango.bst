kind: manual

sources:
- kind: tar
  url: mango_releases:0.17.1/mango-0.17.1.tar.gz
  ref: 033dd3101ab4e0cd9b23011790fbd7519d9802439961aa017f67c6c20b330897

build-depends:
- core/sandbox-tools.bst
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:components/rust.bst

depends:
- freedesktop-sdk.bst:components/wayland.bst
- freedesktop-sdk.bst:components/wayland-protocols.bst
- freedesktop-sdk.bst:components/libxkbcommon.bst
- freedesktop-sdk.bst:components/pango.bst
- freedesktop-sdk.bst:components/cairo.bst
- freedesktop-sdk.bst:components/fontconfig.bst
- freedesktop-sdk.bst:components/dbus.bst
- freedesktop-sdk.bst:components/libdrm.bst
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ""

config:
  build-commands:
  - |
    export CARGO_HOME="/tmp/cargo-home"
    export CARGO_TARGET_DIR="/tmp/cargo-target"
    mkdir -p "$CARGO_HOME" "$CARGO_TARGET_DIR"
    cargo build --release --locked
  install-commands:
  - |
    export CARGO_HOME="/tmp/cargo-home"
    export CARGO_TARGET_DIR="/tmp/cargo-target"
    cargo install --root "%{install-root}%{prefix}" --path . --locked