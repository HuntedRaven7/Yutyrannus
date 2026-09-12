kind: junction

sources:
- kind: git_repo
  url: gnome:gnome-build-meta.git
  track: gnome-51
  ref: e79d494f3c5f69f046517ae9674e2904e0ebfdf6
- kind: patch_queue
  path: patches/gnome-build-meta

config:
  options:
    arch: '%{arch}'
    (?):
    - x86_64_v3:
        x86_64_v3: true

  overrides:
    freedesktop-sdk.bst: freedesktop-sdk.bst

    core/meta-gnome-core-apps.bst: core/meta-gnome-core-apps.bst

    gnomeos-deps/bootc.bst: gnomeos-deps/bootc.bst

    gnomeos-deps/plymouth-gnome-theme.bst: bluefin/plymouth-bluefin-theme.bst

    oci/integration/os-release.bst: oci/os-release.bst

    gnomeos/initramfs/signed-modules.bst: bluefin/unsigned-modules.bst

    plugins/buildstream-plugins.bst: plugins/buildstream-plugins.bst
    plugins/buildstream-plugins-community.bst: plugins/buildstream-plugins-community.bst
