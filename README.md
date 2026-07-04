# Xiaomi SDM845 Kernel — Mi 8 Pro (equuleus)

Linux 4.9.337 kernel for Xiaomi Mi 8 Pro (equuleus).

> [!CAUTION]
> **This kernel is built for LineageOS 22.2 ONLY.**
> Do NOT flash on any other ROM or LineageOS version — kernel interfaces
> change between minor releases and a mismatch WILL cause bootloop or
> hardware breakage. The author assumes **no responsibility** for any
> damage, data loss, or thermonuclear war caused by flashing this kernel.

[![Build equuleus kernel](https://github.com/Harmiel715/xiaomi-sdm845-kernel-pro/actions/workflows/build.yml/badge.svg)](https://github.com/Harmiel715/xiaomi-sdm845-kernel-pro/actions/workflows/build.yml)

## Features

| Feature | Description |
|---|---|
| [ReSukiSU](https://github.com/ReSukiSU/ReSukiSU) | KernelSU fork with extended compatibility (v35002) |
| [SUSFS](https://gitlab.com/simonpunk/susfs4ksu) | Root hiding via filesystem spoofing (v2.1.0) |
| [Baseband Guard](https://github.com/Harmiel715/Baseband-guard) | Baseband security hardening |
| [Droidspaces](https://github.com/ravindu644/Droidspaces-OSS) | Full container support (LXC/Docker-like) |

## Downloads

Pre-built kernel zips are published weekly via GitHub Actions.

👉 **[Latest Release](https://github.com/Harmiel715/xiaomi-sdm845-kernel-pro/releases/latest)**

Each release includes `ak3-equuleus.zip` — flash via TWRP or OrangeFox.

## Building

### Prerequisites

**Arch Linux:**
```bash
sudo pacman -S clang lld aarch64-linux-gnu-binutils aarch64-linux-gnu-gcc \
               arm-linux-gnueabihf-binutils arm-linux-gnueabihf-gcc ccache zip
```

**Ubuntu/Debian:**
```bash
sudo apt install clang lld gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu \
                 gcc-arm-linux-gnueabihf binutils-arm-linux-gnueabihf ccache zip
```

### Build

```bash
git clone --recurse-submodules https://github.com/Harmiel715/xiaomi-sdm845-kernel-pro.git
cd xiaomi-sdm845-kernel-pro
./build_for_equuleus.sh
```

Output: `AnyKernel3/ak3-equuleus.zip`

## Flashing

1. **Kernel**: Flash `ak3-equuleus.zip` via TWRP or OrangeFox
2. **SUSFS module**: Install [susfs4ksu-module](https://github.com/sidex15/susfs4ksu-module) via KernelSU Manager

## Configuration

This kernel is built from three config fragments:

- [`mi845_defconfig`](arch/arm64/configs/vendor/xiaomi/mi845_defconfig) — base SDM845 config
- [`equuleus.config`](arch/arm64/configs/vendor/xiaomi/equuleus.config) — device-specific drivers (touch, fingerprint, GPS, camera)
- [`droidspaces.config`](arch/arm64/configs/vendor/xiaomi/droidspaces.config) — Droidspaces container support

## Adaptations

- **SUSFS workqueue fix** — ReSukiSU requires `susfs_extra_works` which is now defined in `fs/susfs.c`
- **Droidspaces cgroup patch** — applied to `kernel/cgroup.c` for LXC compatibility
- **4.9 config backport** — omitted options not present in this kernel version
- **LLVM toolchain** — switched from broken zyc-clang19 to system clang + LLVM
- **AnyKernel3** — configured for equuleus (A-only, UFS, device check)

## License

GPL-2.0 (see [COPYING](COPYING)). Submodules carry their own licenses.
