kind: manual

sources:
- kind: tar
  url: qt_downloads:6.8/6.8.1/submodules/qtsvg-everywhere-src-6.8.1.tar.xz
  ref: 3d0de73596e36b2daa7c48d77c4426bb091752856912fba720215f756c560dd0

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:components/pkg-config.bst

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