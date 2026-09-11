# Yutyrannus
*Yutyrannus harenipes* — a cutting-edge GNOME OS test-bed image

[GNOME OS](https://os.gnome.org/) built from source with BuildStream 2, tracking GNOME 51 on the latest Linux mainline pre-release kernel with NVIDIA proprietary drivers.

## Image

| Tag | Stream | What it is |
| -----: | ------ | ----------------------------------------------------------------- |
| `:stable` | Stable | GNOME 51 — production. Automated promotion from `:testing`. |
| `:testing` | Dev | GNOME 51 — daily builds from `testing` branch. Boot-check gated. |

```bash
# Install the stable image
sudo bootc switch ghcr.io/robin/yutyrannus-nvidia:stable

# Or switch to testing
sudo bootc switch ghcr.io/robin/yutyrannus-nvidia:testing
```

## Packages

- **brew** — Homebrew package manager (Linuxbrew)
- **ghostty** — GPU-accelerated terminal emulator (built from Zig source)
- **tailscale** — Mesh VPN
- **distrobox** — Containerized development environments
- **sudo-rs** — Memory-safe sudo implementation
- **uutils-coreutils** — Memory-safe coreutils drop-in

## Kernel

Tracks the latest Linux mainline pre-release (`v7.x-rcN`). Bump `elements/core/linux-mainline.bst` when a new `-rc` is desired.

## Building from source

```bash
just build
just boot-vm
```

## Differences from Dakota

Yutyrannus is a simplified fork of [Dakota](https://github.com/projectbluefin/dakota) with:
- GNOME 51 tracking (instead of GNOME 50)
- Linux mainline pre-release kernel (instead of freedesktop-sdk stable)
- NVIDIA-only image (no default variant)
- Simplified build system (no feedback loop, AI agents, cosign/SLSA, SBOM, chunkah)
- No supply-chain signing infrastructure

## Contributing

See [AGENTS.md](AGENTS.md) for build instructions.
