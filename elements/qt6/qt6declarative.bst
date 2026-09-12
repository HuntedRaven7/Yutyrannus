kind: manual

sources:
- kind: tar
  url: qt_downloads:6.8/6.8.1/submodules/qtdeclarative-everywhere-src-6.8.1.tar.xz
  ref: 1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2

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