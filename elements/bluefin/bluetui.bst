kind: manual

sources:
- kind: git_repo
  url: github:pythops/bluetui.git
  track: "v[0-9]*.[0-9]*.[0-9]*"
  ref: v0.8.1-0-gc959c09bb17b

build-depends:
- core/sandbox-tools.bst
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:components/rust.bst

depends:
- freedesktop-sdk.bst:components/bluez.bst
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