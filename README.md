# Yutyrannus
*Yutyrannus harenipes* — a Mango WM Wayland compositor bootc image, built from source.

[Mango](https://github.com/mangowm/mango) is a tiling Wayland compositor written in Rust. Yutyrannus packages it with a curated toolchain and utilities as an OCI desktop image built with BuildStream 2 on top of freedesktop-sdk 26.08.

## Install

```bash
sudo bootc switch ghcr.io/huntedraven7/yutyrannus-nvidia:stable
# or
sudo bootc switch ghcr.io/huntedraven7/yutyrannus-nvidia:testing
```

Requires a bootc-ready base system (e.g. Fedora Silverblue, Bluefin, or another bootc image) and an NVIDIA GPU.

## Stack

| Tag | Stream |
| --- | ------ |
| `:stable` | Production |
| `:testing` | Daily builds from `testing` branch |

### Desktop
- **Mango WM v0.17.0** — tiling Wayland compositor
- **Quickshell v0.3.1** — Qt6 shell/widgets
- **AWWW v0.12.1** — wallpaper daemon
- **Rofi 2.0.0** — application launcher
- **Grim v2.3.73** — screenshot utility
- **Bluetui v0.8.1** — Bluetooth TUI
- **SwayNC v0.9.3** — notification center
- **wlogout v1.2.1** — logout/power menu
- **wl-clipboard v2.3.0** — clipboard utilities
- **polkit-gnome 0.105** — authentication agent
- **brightnessctl v0.5.1** — brightness control
- **playerctl v2.5.1** — media control

### System
- **Ghostty** — GPU-accelerated terminal (built from Zig)
- **Homebrew** — package manager
- **Tailscale** — mesh VPN
- **Distrobox** — containerized development environments
- **sudo-rs** — memory-safe sudo
- **uutils-coreutils** — memory-safe coreutils
- **Flatpak** — sandboxed applications

## Kernel

Tracks the latest Linux mainline pre-release (`v7.x-rcN`).

## Build from Source

```bash
just validate   # BST graph check (~5 min)
just build      # build + export (~60-90 min cold)
just lint       # required before PR
just boot-test  # smoke test in ephemeral VM
just boot-vm    # test in QEMU
```

See `AGENTS.md` for full build instructions and `docs/build.md` for prerequisites.

## Supply Chain

- Cosign keyless Sigstore signing
- SPDX 2.3 SBOM via `buildstream-sbom`
- Chunkah OCI layer optimization
- Remote CAS caching via `cache.projectbluefin.io`

```bash
just verify image_ref="ghcr.io/huntedraven7/yutyrannus-nvidia:stable"
```

## Architecture

- **freedesktop-sdk 26.08** base
- **GNOME 51** libraries for Wayland app compatibility (GTK, Pango, Cairo, GIO)
- **Custom Qt6 6.8.1** built from source for Quickshell
- **NVIDIA 610.57.04** open kernel modules + userspace

## Contributing

See `AGENTS.md` for build instructions, PR workflow, and branch conventions.
