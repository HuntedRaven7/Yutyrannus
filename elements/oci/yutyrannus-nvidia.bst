kind: script

build-depends:
  - gnome-build-meta.bst:freedesktop-sdk.bst:components/fakecap.bst
  - gnome-build-meta.bst:freedesktop-sdk.bst:components/oci-builder.bst
  - gnome-build-meta.bst:sdk/glib.bst
  - gnome-build-meta.bst:core-deps/dconf.bst
  - gnome-build-meta.bst:freedesktop-sdk.bst:vm/prepare-image.bst
  - filename: oci/layers/yutyrannus-nvidia.bst
    config:
      location: /layer

public:
  bst:
    overlap-whitelist:
    - /usr/share/locale/*/LC_MESSAGES/glib20.mo

environment:
  LD_PRELOAD: /usr/libexec/fakecap/fakecap.so
  FAKECAP_DB: /fakecap

variables:
  sysroot-seed: 7f9c5d11-3a26-4b9e-8e21-1d4f3f9e2c57
  image-repo: yutyrannus-nvidia
  (?):
  - gaming == true:
      image-repo: yutyrannus-nvidia-gaming

config:
  commands:
    - mkdir /fakecap
    - |
      prepare-image.sh \
         --sysroot /layer \
         --seed "%{sysroot-seed}" \
         --noroot --noboot >/dev/null

    - |
      systemd-sysusers --root /layer

    - |
      glib-compile-schemas /layer/usr/share/glib-2.0/schemas

    # bootc images must not have both /etc and /usr/etc.
    - |
      if [ -d /layer/usr/etc ]; then
        mkdir -p /layer/etc
        cp -a /layer/usr/etc/. /layer/etc/
        rm -rf /layer/usr/etc
      fi

    - |
      dconf update /layer/etc/dconf/db

    - |
      # FDSDK's Mesa merge path must stay a symlink so libgbm sees both
      # Mesa's DRI backend and NVIDIA's backend on hybrid systems.
      GBM_DIR="/layer%{libdir}/GL/lib/gbm"
      if [ ! -L "$GBM_DIR" ]; then
        echo "FATAL: $GBM_DIR is not the FDSDK Mesa merge symlink" >&2
        exit 1
      fi
      for backend in dri_gbm.so nvidia-drm_gbm.so; do
        if [ ! -e "$GBM_DIR/$backend" ]; then
          echo "FATAL: GBM backend $GBM_DIR/$backend is missing" >&2
          exit 1
        fi
      done

    - |
      cd "%{install-root}"
      build-oci <<EOF
      mode: oci
      gzip: disabled
      images:
      - os: linux
        architecture: "%{go-arch}"
        layer: /layer
        comment: "Import Yutyrannus NVIDIA image"
        config:
          Labels:
            'com.github.containers.toolbox': 'true'
            'org.opencontainers.image.title': 'Yutyrannus NVIDIA'
            'org.opencontainers.image.description': 'A cutting-edge GNOME OS testbed image with NVIDIA proprietary driver'
            'org.opencontainers.image.vendor': 'Yutyrannus'
            'org.opencontainers.image.licenses': 'Apache-2.0 AND LicenseRef-NVIDIA-SLA'
            'org.opencontainers.image.url': 'https://yutyrannus.io'
            'org.opencontainers.image.source': 'https://github.com/robin/yutyrannus'
            'containers.bootc': '1'
        index-annotations:
           'org.opencontainers.image.ref.name': 'ghcr.io/robin/yutyrannus-nvidia:%{image-repo}:latest'
      EOF
