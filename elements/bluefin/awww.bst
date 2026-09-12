kind: manual

sources:
- kind: tar
  url: codeberg_files:LGFae/awww/archive/v0.12.1.tar.gz
  ref: 1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2

build-depends:
- core/sandbox-tools.bst
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:components/rust.bst

depends:
- freedesktop-sdk.bst:components/wayland.bst
- freedesktop-sdk.bst:components/wayland-protocols.bst
- bluefin/gtk4-layer-shell.bst
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