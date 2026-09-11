kind: manual

sources:
- kind: local
  path: files/just-overrides

build-depends:
- core/sandbox-tools.bst
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

depends:
- freedesktop-sdk.bst:components/python3.bst

variables:
  strip-binaries: ""

public:
  bst:
    overlap-whitelist:
    - /usr/share/ublue-os/just/default.just
    - /usr/share/ublue-os/just/changelog.just
    - /usr/share/ublue-os/just/system.just

config:
  install-commands:
  - install -Dm644 default.just "%{install-root}/usr/share/ublue-os/just/default.just"
  - install -Dm644 changelog.just "%{install-root}/usr/share/ublue-os/just/changelog.just"
  - install -Dm644 system.just "%{install-root}/usr/share/ublue-os/just/system.just"
  - install -Dm755 devmode.py "%{install-root}/usr/libexec/yutyrannus-devmode"
  - install -Dm644 flutter.just "%{install-root}/usr/share/ublue-os/just/flutter.just"
  - install -Dm644 yutyrannus-dev-flatpaks.Brewfile "%{install-root}/usr/share/ublue-os/homebrew/yutyrannus-dev-flatpaks.Brewfile"
  - install -Dm644 yutyrannus-fonts.Brewfile "%{install-root}/usr/share/ublue-os/homebrew/yutyrannus-fonts.Brewfile"
  - "%{install-extra}"
