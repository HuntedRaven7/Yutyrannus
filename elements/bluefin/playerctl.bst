kind: meson

sources:
- kind: tar
  url: playerctl_releases:v2.4.1/playerctl-2.4.1.tar.gz
  ref: 75957ad5071956f563542c7557af16a57e40b4a7f66bc9b6373d022ec5eef548

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:components/glib.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

config:
  install-commands:
  - meson install --destdir "%{install-root}"