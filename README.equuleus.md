# Xiaomi Mi 8 Pro (equuleus) — Kernel Build Guide

Kernel 4.9.337 for Xiaomi Mi 8 Pro (equuleus / ursa), based on SDM845.

## Features

| Feature | Status | Config |
|---|---|---|
| ReSukiSU (KernelSU fork) | ✅ | `CONFIG_KSU=y`, version 35002 |
| SUSFS (root hiding) | ✅ | `CONFIG_KSU_SUSFS=y` v2.1.0 + workqueue fix |
| Baseband Guard | ✅ | `CONFIG_BBG=y` |
| Droidspaces (container) | ✅ | Full mandatory + UFW/Fail2ban support |
| equuleus device drivers | ✅ | Touch, fingerprint, GPS, camera |

## Quick Start

### Prerequisites

```bash
# Arch Linux
sudo pacman -S clang lld aarch64-linux-gnu-binutils aarch64-linux-gnu-gcc \
               arm-linux-gnueabihf-binutils arm-linux-gnueabihf-gcc ccache zip
```

### Build

```bash
git clone --recurse-submodules <this-repo>
cd xiaomi-sdm845-kernel-resukisu-susfs
./build_for_equuleus.sh
```

Output: `AnyKernel3/ak3-equuleus.zip`

### Flash

1. Flash `ak3-equuleus.zip` via TWRP/OrangeFox
2. Install `susfs4ksu-module` via KernelSU Manager (userspace tools for SUSFS)

## Submodules

| Submodule | Source | Commit |
|---|---|---|
| KernelSU | https://github.com/ReSukiSU/ReSukiSU.git | `54e7551e` |
| AnyKernel3 | https://github.com/osm0sis/AnyKernel3.git | `dca9dc3` |

## Configuration Fragments

- `arch/arm64/configs/vendor/xiaomi/mi845_defconfig` — base SDM845 config
- `arch/arm64/configs/vendor/xiaomi/equuleus.config` — device-specific drivers
- `arch/arm64/configs/vendor/xiaomi/droidspaces.config` — Droidspaces container support

## Adaptations from Upstream

### SUSFS workqueue fix

ReSukiSU commit `639e2e36` migrated `susfs_run_sus_path_loop()` to a workqueue
model. The in-tree SUSFS (v2.1.0) lacked the `susfs_extra_works` work_struct.
Added in `fs/susfs.c`:
- `susfs_extra_work_handler()` — workqueue wrapper
- `struct work_struct susfs_extra_works` — scheduled by KSU umount handler
- `INIT_WORK()` — bound in `susfs_init()`

### Droidspaces non-GKI patches

- **Patch applied**: `02.fix_restore cgroup file prefix handling` — adapted
  `kernel/cgroup/cgroup.c` → `kernel/cgroup.c` (4.9 path difference).
  Adds subsystem-prefixed symlinks for LXC/Droidspaces cgroup compatibility.
- **Patch skipped**: `01.fix_kernel_panic_in_xt_qtaguid` — this kernel has
  no `xt_qtaguid` module.

### Droidspaces config adaptations for 4.9

Options absent in 4.9 and omitted:
- `CONFIG_FW_LOADER_COMPRESS` — not in 4.9
- `CONFIG_NETFILTER_XT_TARGET_MASQUERADE` — use `CONFIG_IP_NF_TARGET_MASQUERADE`
- `CONFIG_NETFILTER_XT_TARGET_REJECT` — use `CONFIG_IP_NF_TARGET_REJECT`
- `CONFIG_IP_NF_TARGET_ULOG` — not in 4.9
- `CONFIG_ANDROID_PARANOID_NETWORK` — not in this kernel
- `CONFIG_NF_CONNTRACK_NETLINK` — renamed to `CONFIG_NF_CT_NETLINK` in 4.9
- `CONFIG_FW_LOADER_USER_HELPER` — use `CONFIG_FW_LOADER_USER_HELPER_FALLBACK`

### Build toolchain

Switched from zyc-clang19 (broken) to system clang + LLVM tools.
ARM32 VDSO uses `arm-linux-gnueabihf-gcc` (GNU) to avoid lld's lack of
`armelf_linux_eabi` emulation.

## Cleanup from Upstream

- Removed broken `susfs4ksu` gitlink (SUSFS patches are in-tree)
- Removed stale `build.log` and `pstore/` crash dumps
- Added `/build.log`, `/out/`, `/pstore/` to `.gitignore`
- Fixed whitespace in `arch/arm64/boot/dts/qcom/Makefile`
- Changed `LOCALVERSION` to `-perf-equuleus`

## References

- SUSFS kernel patches: https://gitlab.com/simonpunk/susfs4ksu (branch `kernel-4.9`)
- SUSFS userspace module: https://github.com/sidex15/susfs4ksu-module
- Droidspaces: https://github.com/ravindu644/Droidspaces-OSS
- ReSukiSU: https://github.com/ReSukiSU/ReSukiSU
