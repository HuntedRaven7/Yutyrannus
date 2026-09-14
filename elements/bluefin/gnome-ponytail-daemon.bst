kind: meson

sources:
- kind: git_repo
  url: gnome_gitlab:ofourdan/gnome-ponytail-daemon.git
  track: "master"
  ref: ccda14c1132753bcb6d3e74f6a361ba915a15000

variables:
  conf-flags: >-
    -Dsystemd_user_unit_dir=/usr/lib/systemd/user

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/python3.bst
- freedesktop-sdk.bst:components/systemd.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- gnome-build-meta.bst:sdk/glib.bst
- freedesktop-sdk.bst:components/libei.bst
- freedesktop-sdk.bst:components/libxkbcommon.bst
