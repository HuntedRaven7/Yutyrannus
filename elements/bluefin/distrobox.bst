# Override: distrobox next branch (Go port).
# Replaces gnome-build-meta.bst:gnomeos-deps/distrobox.bst (shell-based).
# Tracks 89luca89/distrobox:next — the full Go rewrite.
kind: manual

build-depends:
- core/sandbox-tools.bst
- freedesktop-sdk.bst:components/go.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

runtime-depends:
- freedesktop-sdk.bst:components/podman.bst

variables:
  strip-binaries: ""

environment:
  GOROOT: "%{libdir}/go"
  GOARCH: "%{go-arch}"

config:
  build-commands:
  - mv -vf modules.txt vendor/modules.txt
  - CGO_ENABLED=0 go build -mod=vendor -ldflags="-s -w" -o ./bin/distrobox ./cmd/distrobox

  install-commands:
  - install -Dm755 ./bin/distrobox "%{install-root}%{bindir}/distrobox"
  - |
    for cmd in assemble create enter ephemeral generate-entry list ls rm stop upgrade; do
      ln -sf distrobox "%{install-root}%{bindir}/distrobox-${cmd}"
    done
  - install -Dm644 completions/bash/distrobox "%{install-root}%{datadir}/bash-completion/completions/distrobox"
  - install -Dm644 completions/zsh/_distrobox "%{install-root}%{datadir}/zsh/site-functions/_distrobox"
  - install -d "%{install-root}%{mandir}/man1"
  - install -m644 man/man1/*.1 "%{install-root}%{mandir}/man1/"
  - "%{install-extra}"

sources:
- kind: git_repo
  url: github:89luca89/distrobox.git
  track: next
  ref: 1.8.2.5-192-gc7478fdf5fa38fc7d07c4546e2684fa4a2dfe3b8

- kind: local
  path: files/distrobox/modules.txt

- kind: go_module
  url: github:davecgh/go-spew.git
  module: github.com/davecgh/go-spew
  ref:
    go-version: v1.1.1
    git-ref: v1.1.1
    explicit: True

- kind: go_module
  url: github:pmezard/go-difflib.git
  module: github.com/pmezard/go-difflib
  ref:
    go-version: v1.0.0
    git-ref: v1.0.0
    explicit: True

- kind: go_module
  url: github:stretchr/testify.git
  module: github.com/stretchr/testify
  ref:
    go-version: v1.11.1
    git-ref: v1.11.1
    explicit: True

- kind: go_module
  url: github:urfave/cli.git
  module: github.com/urfave/cli/v3
  ref:
    go-version: v3.5.0
    git-ref: v3.5.0
    explicit: True

- kind: go_module
  url: github:go-ini/ini.git
  module: gopkg.in/ini.v1
  ref:
    go-version: v1.67.0
    git-ref: v1.67.0
    explicit: True

- kind: go_module
  url: github:go-yaml/yaml.git
  module: gopkg.in/yaml.v3
  ref:
    go-version: v3.0.1
    git-ref: v3.0.1
    explicit: True
