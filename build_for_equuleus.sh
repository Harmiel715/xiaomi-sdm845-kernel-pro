#!/usr/bin/env bash
set -euo pipefail

export ARCH=arm64
export SUBARCH=arm64
export USE_CCACHE=1

OUT_DIR="${OUT_DIR:-out}"
DEFCONFIG="vendor/xiaomi/mi845_defconfig"
DEVICE_CONFIG="arch/arm64/configs/vendor/xiaomi/equuleus.config"
DROIDSPACES_CONFIG="arch/arm64/configs/vendor/xiaomi/droidspaces.config"
IMAGE="${OUT_DIR}/arch/arm64/boot/Image.gz-dtb"

if [ ! -f KernelSU/kernel/Kconfig ]; then
	echo "Missing KernelSU sources."
	echo "Run: git submodule update --init --recursive KernelSU"
	exit 1
fi

# Use system clang + LLVM tools
CC="clang"
AR="llvm-ar"
NM="llvm-nm"
STRIP="llvm-strip"
OBJCOPY="llvm-objcopy"
OBJDUMP="llvm-objdump"
READELF="llvm-readelf"
LLVM_IAS=1

CROSS_COMPILE="aarch64-linux-gnu-"
CROSS_COMPILE_ARM32="arm-linux-gnueabihf-"
CROSS_COMPILE_COMPAT="arm-linux-gnueabihf-"

# Verify toolchain
for tool in clang llvm-ar aarch64-linux-gnu-objcopy arm-linux-gnueabihf-gcc; do
	if ! command -v "$tool" >/dev/null 2>&1; then
		echo "Missing required tool: $tool"
		echo "Arch:  sudo pacman -S clang lld aarch64-linux-gnu-binutils arm-linux-gnueabihf-binutils arm-linux-gnueabihf-gcc"
		echo "Debian/Ubuntu: sudo apt install clang lld gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu gcc-arm-linux-gnueabihf binutils-arm-linux-gnueabihf"
		exit 1
	fi
done

# ccache wrapper
if command -v ccache >/dev/null 2>&1; then
	CC="ccache ${CC}"
	export CCACHE_EXEC="$(command -v ccache)"
fi

make O="${OUT_DIR}" ARCH=arm64 clean
make O="${OUT_DIR}" ARCH=arm64 mrproper
make O="${OUT_DIR}" ARCH=arm64 "${DEFCONFIG}"
scripts/kconfig/merge_config.sh -O "${OUT_DIR}/" "${OUT_DIR}/.config" "${DEVICE_CONFIG}"
scripts/kconfig/merge_config.sh -O "${OUT_DIR}/" "${OUT_DIR}/.config" "${DROIDSPACES_CONFIG}"

make -j"$(nproc)" -Orecurse O="${OUT_DIR}" ARCH=arm64 \
	CC="${CC}" \
	AR="${AR}" \
	NM="${NM}" \
	STRIP="${STRIP}" \
	OBJCOPY="${OBJCOPY}" \
	OBJDUMP="${OBJDUMP}" \
	READELF="${READELF}" \
	LLVM_IAS="${LLVM_IAS}" \
	CROSS_COMPILE="${CROSS_COMPILE}" \
	CROSS_COMPILE_ARM32="${CROSS_COMPILE_ARM32}" \
	CROSS_COMPILE_COMPAT="${CROSS_COMPILE_COMPAT}" \
	CC_ARM32="arm-linux-gnueabihf-gcc" \
		KCFLAGS="-Wno-error"

if [ ! -f "${IMAGE}" ]; then
	echo "Build failed: ${IMAGE} was not generated."
	exit 1
fi

echo "Build successful: ${IMAGE}"

if [ -f AnyKernel3/anykernel.sh ]; then
	echo "Packaging equuleus kernel with AnyKernel3..."
	cp "${IMAGE}" AnyKernel3/
	(
		cd AnyKernel3
		zip -r9 "ak3-equuleus.zip" . -x .git README.md "ak3-*.zip"
	)
	echo "Done: AnyKernel3/ak3-equuleus.zip"
else
	echo "AnyKernel3 is not initialized; skip packaging."
	echo "Run: git submodule update --init --recursive AnyKernel3"
fi
