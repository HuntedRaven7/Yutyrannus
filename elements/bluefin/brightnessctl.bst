kind: make

sources:
- kind: tar
  url: brightnessctl_releases:v0.5.1/brightnessctl-0.5.1.tar.gz
  ref: 1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

config:
  install-commands:
  - |
    make install DESTDIR="%{install-root}" PREFIX="/usr"