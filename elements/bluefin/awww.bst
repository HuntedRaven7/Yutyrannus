kind: manual

sources:
- kind: tar
  url: codeberg_files:LGFae/awww/archive/v0.12.1.tar.gz
  ref: 97b3f1c6d65d9d30e51b17092a45244f8c8549607c9207f3c98d82b28ba18fca

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