kind: manual

sources:
- kind: local
  path: files/firstboot

build-depends:
- core/sandbox-tools.bst
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ""

config:
  install-commands:
  - install -Dm644 ublue-firstboot-date.service "%{install-root}/usr/lib/systemd/system/ublue-firstboot-date.service"
  - install -Dm644 yutyrannus-remove-installer.service "%{install-root}/usr/lib/systemd/system/yutyrannus-remove-installer.service"
  - install -Dm644 ublue-booted-image.service "%{install-root}/usr/lib/systemd/system/ublue-booted-image.service"
  - install -Dm755 ublue-booted-image-sync "%{install-root}/usr/bin/ublue-booted-image-sync"
  - mkdir -p "%{install-root}/usr/lib/systemd/system/multi-user.target.wants/"
  - ln -sf ../ublue-firstboot-date.service "%{install-root}/usr/lib/systemd/system/multi-user.target.wants/ublue-firstboot-date.service"
  - ln -sf ../yutyrannus-remove-installer.service "%{install-root}/usr/lib/systemd/system/multi-user.target.wants/yutyrannus-remove-installer.service"
  - ln -sf ../ublue-booted-image.service "%{install-root}/usr/lib/systemd/system/multi-user.target.wants/ublue-booted-image.service"
  - "%{install-extra}"
