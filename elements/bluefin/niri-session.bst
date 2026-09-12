kind: manual

sources:
- kind: local
  path: files/niri

build-depends:
- core/sandbox-tools.bst
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

depends:
- bluefin/niri.bst

config:
  install-commands:
  - cp -r usr/./ "%{install-root}%{prefix}/"