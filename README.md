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

## Supply chain

- **SBOM**: SPDX 2.3 generated with `buildstream-sbom`, attached as OCI referrer via `oras`, signed with cosign
- **Cosign**: Keyless Sigstore OIDC signing of image and SBOM
- **Chunkah**: OCI layer optimization via `quay.io/coreos/chunkah:v0.6.0` with `fakecap` xattr restoration
- **CAS cache**: BuildStream artifacts cached in GitHub Actions (`actions/cache@v6`) and remotely via `cache.projectbluefin.io`

## Building from source

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

## Differences from Dakota

Yutyrannus is a fork of [Dakota](https://github.com/projectbluefin/dakota) with:
- GNOME 51 tracking (instead of GNOME 50)
- Linux mainline pre-release kernel (instead of freedesktop-sdk stable)
- NVIDIA-only image (no default variant)
- Supply chain security: SBOM, cosign, chunkah, CAS cache

## Contributing

See [AGENTS.md](AGENTS.md) for build instructions.
