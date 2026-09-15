kind: manual

sources:
# ref verified against Qt's own MirrorBrain metadata for this file
# (download.qt.io/.../qt-everywhere-src-6.8.1.tar.xz.mirrorlist, SHA-256),
# which matches the tarball served over HTTPS. The previous ref did not
# match anything Qt publishes.
- kind: tar
  url: qt_downloads:6.8/6.8.1/single/qt-everywhere-src-6.8.1.tar.xz
  ref: 45e3a9f6d33c92ffe65a1fde1a8eba5b228112df675f7f9026eaa332b2e2edff

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:components/perl.bst
- freedesktop-sdk.bst:components/python3.bst
- freedesktop-sdk.bst:components/bison.bst
- freedesktop-sdk.bst:components/flex.bst
- freedesktop-sdk.bst:components/gperf.bst

depends:
- freedesktop-sdk.bst:components/zlib.bst
- freedesktop-sdk.bst:components/libpng.bst
- freedesktop-sdk.bst:components/freetype.bst
- freedesktop-sdk.bst:components/harfbuzz.bst
- freedesktop-sdk.bst:components/sqlite.bst
- freedesktop-sdk.bst:components/libxml2.bst
- freedesktop-sdk.bst:components/openssl.bst
- freedesktop-sdk.bst:components/wayland.bst
- freedesktop-sdk.bst:components/wayland-protocols.bst
- freedesktop-sdk.bst:components/libxkbcommon.bst
- freedesktop-sdk.bst:components/libdrm.bst
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
      -DFEATURE_system_zlib=ON \
      -DFEATURE_system_libpng=ON \
      -DFEATURE_system_freetype=ON \
      -DFEATURE_system_harfbuzz=ON \
      -DFEATURE_system_sqlite=ON \
      -DFEATURE_system_libxml2=ON \
      -DFEATURE_openssl=ON \
      -DFEATURE_openssl_linked=ON \
      -DFEATURE_wayland=ON \
      -DFEATURE_xkbcommon=ON \
      -DFEATURE_dbus=ON \
      -DFEATURE_gtk=OFF
  - |
    cmake --build build --parallel $(nproc)
  install-commands:
  - |
    cmake --install build --prefix "%{install-root}%{prefix}"