kind: junction

sources:
- kind: git_repo
  url: https://gitlab.com/freedesktop-sdk/freedesktop-sdk.git
  track: freedesktop-sdk-25.08*
  ref: 9cca827b6a528108375f6131d86bb728842b66f4
- kind: patch_queue
  path: patches/freedesktop-sdk

config:
  options:
    arch: '%{arch}'
    (?):
    - x86_64_v3:
        x86_64_v3: true

  overrides:
    freedesktop-sdk.bst: freedesktop-sdk.bst

    components/linux.bst: core/linux-mainline.bst
    (?):
    - gaming == true:
        components/linux.bst: core/linux-ogc.bst

    public-stacks/runtime-gnu.bst: freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
