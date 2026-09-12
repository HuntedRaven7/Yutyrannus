kind: stack

depends:
  - bluefin/deps.bst
  - oci/os-release.bst

  - freedesktop-sdk.bst:components/linux-firmware.bst
  - core/ntsync-modules-load.bst
  - gnome-build-meta.bst:gnomeos/initramfs/signed-modules.bst
  - gnome-build-meta.bst:oci/initramfs/image.bst

  - gnome-build-meta.bst:gnomeos-deps/bootc.bst
  - gnome-build-meta.bst:oci/integration/bootc-config.bst
  - freedesktop-sdk.bst:vm/config/useradd-default.bst
  - freedesktop-sdk.bst:vm/config/sudo.bst

  - bluefin-nvidia/deps.bst

public:
  bst:
    integration-commands:
    # Re-run depmod against the composed root so modprobe sees the
    # NVIDIA modules alongside FDSDK's modules.dep entries for the
    # in-tree modules (nvidia-drm → nvidia-modeset → nvidia).
    - |
      KVER=$(ls /usr/lib/modules | head -n1)
      if [ -z "$KVER" ]; then
          echo "FATAL: no kernel under /usr/lib/modules at integration time" >&2
          exit 1
      fi
      depmod -a "$KVER"
