kind: manual

sources:
- kind: git_repo
  url: github:mangowm/mango.git
  track: "[0-9]*.[0-9]*.[0-9]*"
  ref: c45746cb9cfa00e438473df19556ef2d12ff713a

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