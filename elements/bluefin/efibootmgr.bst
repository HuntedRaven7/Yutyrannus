kind: make

sources:
- kind: git_repo
  url: github:rhboot/efibootmgr.git
  track: "18"
  ref: 18

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- freedesktop-sdk.bst:components/pkg-config.bst

depends:
- freedesktop-sdk.bst:components/efivar.bst
- freedesktop-sdk.bst:components/popt.bst
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  make-args: EFIDIR=bluefin sbindir=%{bindir}
