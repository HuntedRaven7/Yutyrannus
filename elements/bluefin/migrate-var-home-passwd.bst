kind: manual
description: |
  One-shot, idempotent boot-time migration of legacy /var/home/<user> (and
  /var/roothome) passwd home fields to the post-#1117 bind-mount layout.
  Installs from before 2026-06-29 carry the old fields, which breaks snapd
  and makes path-identity comparisons disagree; see
  robin/yutyrannus#1170.

  Ships the migration script, its oneshot unit (ordered before
  systemd-user-sessions), and a preset to enable it.

sources:
- kind: local
  path: files/migrate-var-home-passwd

build-depends:
- core/sandbox-tools.bst
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ""

config:
  install-commands:
  - |
    install -Dm755 yutyrannus-migrate-var-home-passwd \
            "%{install-root}/usr/libexec/yutyrannus-migrate-var-home-passwd"
  - |
    install -Dm644 yutyrannus-migrate-var-home-passwd.service \
            "%{install-root}%{indep-libdir}/systemd/system/yutyrannus-migrate-var-home-passwd.service"
  - |
    install -Dm644 /dev/null "%{install-root}%{indep-libdir}/systemd/system-preset/80-yutyrannus-migrate-var-home-passwd.preset"
    cat > "%{install-root}%{indep-libdir}/systemd/system-preset/80-yutyrannus-migrate-var-home-passwd.preset" <<'PRESET'
    enable yutyrannus-migrate-var-home-passwd.service
    PRESET
