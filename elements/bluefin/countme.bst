kind: manual

sources:
- kind: local
  path: files/countme

build-depends:
- core/sandbox-tools.bst
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ""

config:
  install-commands:
  - install -Dm644 yutyrannus-countme.{service,timer} -t "%{install-root}/usr/lib/systemd/system/"
  - mkdir -p "%{install-root}/usr/lib/systemd/system/timers.target.wants/"
  - ln -sf ../yutyrannus-countme.timer "%{install-root}/usr/lib/systemd/system/timers.target.wants/yutyrannus-countme.timer"
  - install -Dm755 yutyrannus-countme "%{install-root}/usr/libexec/yutyrannus-countme"
