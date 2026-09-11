kind: junction

sources:
- kind: git_repo
  url: https://gitlab.com/freedesktop-sdk/freedesktop-sdk.git
  track: freedesktop-sdk-25.08*
  ref: 9cca827b6a528108375f6131d86bb728842b66f4
- kind: patch_queue
  path: patches/freedesktop-sdk

config:
  overrides:
    components/linux.bst: core/linux-mainline.bst
    (?):
    - gaming == true:
        components/linux.bst: core/linux-ogc.bst
