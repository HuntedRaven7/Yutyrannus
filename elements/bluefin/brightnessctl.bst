kind: make

sources:
- kind: tar
  url: brightnessctl_releases:v0.5.1/brightnessctl-0.5.1.tar.gz
  ref: a68869e23f56ac4f2e28f1783002810ddbf10f95e1af9b48b2912fb169f46994

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

config:
  install-commands:
  - |
    make install DESTDIR="%{install-root}" PREFIX="/usr"