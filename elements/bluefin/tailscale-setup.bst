kind: manual

sources:
- kind: local
  path: files/tailscale

build-depends:
- core/sandbox-tools.bst

depends:
- bluefin/tailscale.bst
- gnome-build-meta.bst:sdk/pygobject.bst
- gnome-build-meta.bst:sdk/libadwaita.bst
- freedesktop-sdk.bst:components/polkit.bst

variables:
  strip-binaries: ""

config:
  install-commands:
  - install -Dm755 yutyrannus-tailscale-setup "%{install-root}%{prefix}/libexec/yutyrannus-tailscale-setup"
  - install -Dm755 yutyrannus-tailscale-authorize "%{install-root}%{prefix}/libexec/yutyrannus-tailscale-authorize"
  - install -Dm644 org.yutyrannus.TailscaleSetup.desktop "%{install-root}%{datadir}/applications/org.yutyrannus.TailscaleSetup.desktop"
  - install -Dm644 org.yutyrannus.tailscale.policy "%{install-root}%{datadir}/polkit-1/actions/org.yutyrannus.tailscale.policy"
  - "%{install-extra}"
