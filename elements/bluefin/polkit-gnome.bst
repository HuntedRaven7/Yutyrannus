kind: meson

sources:
- kind: git_repo
  url: gnome:polkit-gnome
  track: "[0-9]*.[0-9]*.[0-9]*"
  ref: 0.107-0-g5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:components/glib.bst
- gnome-build-meta.bst:sdk/gtk.bst
- freedesktop-sdk.bst:components/polkit.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

config:
  install-commands:
  - meson install --destdir "%{install-root}"