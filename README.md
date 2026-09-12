# Yutyrannus
*Yutyrannus harenipes* — a Niri WM Wayland compositor image built from source

[Niri](https://github.com/niri-wm/niri) — a scrollable-tiling Wayland compositor, built from source with BuildStream 2 on top of freedesktop-sdk 26.08 with NVIDIA proprietary drivers.

## Image

| Tag | Stream | What it is |
| -----: | ------ | ----------------------------------------------------------------- |
| `:stable` | Stable | Niri WM — production. Automated promotion from `:testing`. |
| `:testing` | Dev | Niri WM — daily builds from `testing` branch. Boot-check gated. |

```bash
# Install the stable image
sudo bootc switch ghcr.io/robin/yutyrannus-nvidia:stable

# Or switch to testing
sudo bootc switch ghcr.io/robin/yutyrannus-nvidia:testing
```

## Desktop Environment

- **Niri WM v26.04** — Scrollable-tiling Wayland compositor (Rust/cargo)
- **Quickshell v0.3.1** — Qt6-based shell/widgets (built from source with custom Qt6)
- **AWWW v0.12.1** — Wallpaper daemon (Rust/cargo)
- **Rofi 2.0.0** — Application launcher (meson)
- **Grim v2.3.73** — Wayland screenshot utility (meson)
- **Bluetui v0.8.1** — Bluetooth TUI (Rust/cargo)
- **SwayNC v0.9.3** — Notification center (meson)
- **wlogout v1.2.1** — Logout/power menu (meson)
- **wl-clipboard v2.3.0** — Wayland clipboard utilities
- **polkit-gnome 0.105** — Authentication agent
- **brightnessctl v0.5.1** — Brightness control
- **playerctl v2.5.1** — MPRIS media control

## System Packages

- **brew** — Homebrew package manager (Linuxbrew)
- **ghostty** — GPU-accelerated terminal emulator (built from Zig source)
- **tailscale** — Mesh VPN
- **distrobox** — Containerized development environments
- **sudo-rs** — Memory-safe sudo implementation
- **uutils-coreutils** — Memory-safe coreutils drop-in

## Auto-Login

GDM auto-login for the first-boot user created by the installer (Omarchy-style). A oneshot systemd service detects the first non-root user (UID 1000-60000) and configures GDM auto-login before `gdm.service` starts.

## Kernel

Tracks the latest Linux mainline pre-release (`v7.x-rcN`). Bump `elements/core/linux-mainline.bst` when a new `-rc` is desired.

## Supply Chain

- **SBOM**: SPDX 2.3 generated with `buildstream-sbom`, attached as OCI referrer via `oras`, signed with cosign
- **Cosign**: Keyless Sigstore OIDC signing of image and SBOM
- **Chunkah**: OCI layer optimization via `quay.io/coreos/chunkah:v0.6.0` with `fakecap` xattr restoration
- **CAS cache**: BuildStream artifacts cached in GitHub Actions (`actions/cache@v6`) and remotely via `cache.projectbluefin.io`

## Building from Source

```bash
just build          # build + export + chunkify
just sbom           # generate SBOM
just boot-vm        # test in QEMU
just verify         # verify cosign + SBOM + attestation
```

## CI

- `build.yml` — BuildStream build, export, push to GHCR
- `publish.yml` — Chunkify, lint, audit, sign, attach SBOM, promote stream tags
- `validate.yml` — PR validation: `bst show`, patch checks, image variant matrix
- `publish-smoke.yml` — Observational smoke tests after publish

## Architecture

Yutyrannus is a BuildStream 2 bootc OCI image built on:
- **freedesktop-sdk 26.08** — Base SDK
- **gnome-build-meta (GNOME 51 branch)** — GNOME libraries (GTK, Pango, Cairo, etc.) for Wayland app compatibility
- **Custom Qt6 6.8.1** — Built from source (qt6base, qt6declarative, qt6svg, qt6wayland) for Quickshell
- **NVIDIA 610.57.04** — Open kernel modules + userspace from `.run` installer

## Contributing

See [AGENTS.md](AGENTS.md) for build instructions.