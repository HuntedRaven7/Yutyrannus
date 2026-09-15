# MATE polkit authentication agent for the mango/Niri sessions.
#
# GNOME Shell ships its own agent, but Niri needs a standalone one.
# Replaces the old polkit-gnome element: upstream polkit-gnome is abandoned
# at 0.105 and has no fetchable git repo, while mate-polkit is maintained.
kind: meson

sources:
# ref is the upstream-published sha256 for this release tarball
# (mate-polkit-1.28.1.tar.xz.sha256sum alongside the release), verified
# against the downloaded bytes.
- kind: tar
  url: github-releases:mate-desktop/mate-polkit/releases/download/v1.28.1/mate-polkit-1.28.1.tar.xz
  ref: 350a1dd0a8ed6a2c9c183cff2a21f394299e968fcc6ae2e8c93c565dae604ae8

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:components/glib.bst
- freedesktop-sdk.bst:components/gtk3.bst
- freedesktop-sdk.bst:components/polkit-gobject.bst
- freedesktop-sdk.bst:components/polkit.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

config:
  install-commands:
  - meson install --destdir "%{install-root}"
