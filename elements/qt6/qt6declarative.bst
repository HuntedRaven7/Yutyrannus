kind: manual

sources:
- kind: tar
  url: qt_downloads:6.8/6.8.1/submodules/qtdeclarative-everywhere-src-6.8.1.tar.xz
  ref: 95d15d5c1b6adcedb1df6485219ad13b8dc1bb5168b5151f2f1f7246a4c039fc

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:components/perl.bst
- freedesktop-sdk.bst:components/python3.bst

depends:
- qt6/qt6base.bst
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ""

config:
  build-commands:
  - |
    cmake -S . -B build \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_BUILD_TYPE=Release \
      -DQT_BUILD_EXAMPLES=OFF \
      -DQT_BUILD_TESTS=OFF \
      -DQt6_DIR="%{depdir:qt6/qt6base.bst}%{prefix}/lib/cmake/Qt6"
  - |
    cmake --build build --parallel $(nproc)
  install-commands:
  - |
    cmake --install build --prefix "%{install-root}%{prefix}"