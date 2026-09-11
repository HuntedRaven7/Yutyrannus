kind: meson

sources:
- kind: git_repo
  url: github:gsconnect/gnome-shell-extension-gsconnect.git
  track: v*
  ref: v72-0-g1a6230dff3247b9e014a9d32f7909b944ecf1097

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/desktop-file-utils.bst

depends:
- freedesktop-sdk.bst:components/gettext.bst
- gnome-build-meta.bst:sdk/glib.bst
- gnome-build-meta.bst:core/gnome-shell.bst

variables:
  strip-binaries: ""
