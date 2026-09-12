kind: manual

sources:
- kind: local
  path: files/firstboot
- kind: local
  path: files/service-overrides

build-depends:
- core/sandbox-tools.bst
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ""

config:
  install-commands:
  - install -Dm644 ublue-boot-timeout.service "%{install-root}/usr/lib/systemd/system/ublue-boot-timeout.service"
  - install -d "%{install-root}/usr/lib/systemd/system/multi-user.target.wants"
  - ln -sf ../ublue-boot-timeout.service "%{install-root}/usr/lib/systemd/system/multi-user.target.wants/ublue-boot-timeout.service"
  - install -Dm644 "flatpak-preinstall.service.d/condition-check.conf" "%{install-root}/usr/lib/systemd/system/flatpak-preinstall.service.d/condition-check.conf"
  - install -Dm644 yutyrannus-gdm-autologin.service "%{install-root}/usr/lib/systemd/system/yutyrannus-gdm-autologin.service"
  - install -Dm755 yutyrannus-gdm-autologin.sh "%{install-root}/usr/libexec/yutyrannus-gdm-autologin.sh"
  - install -d "%{install-root}/usr/lib/systemd/system/multi-user.target.wants"
  - ln -sf ../yutyrannus-gdm-autologin.service "%{install-root}/usr/lib/systemd/system/multi-user.target.wants/yutyrannus-gdm-autologin.service"
  - "%{install-extra}"
