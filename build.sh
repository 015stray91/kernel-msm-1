#!/bin/bash
set -euo pipefail

# ========== CONFIGURATION ==========
KSU_VARIANT="KernelSU-Next"
ADD_SUSFS=true
ADD_ZEROMOUNT=true
ADD_ZRAM=true
ADD_BBG=true
ADD_OVERLAYFS=true
ADD_KPM=true
# ===================================

# Free disk space
sudo apt-get update
sudo apt-get install -y endersonmenezes/free-disk-space
free-disk-space --remove-android --remove-tool-cache

# Install toolchain
sudo apt-get install -y clang-12 lld-12 llvm-12 gcc-aarch64-linux-gnu \
  binutils bc bison flex libssl-dev libelf-dev cpio kmod python3 \
  make device-tree-compiler

# Clone common into existing kernel-msm-1
cd kernel-msm-1
git clone --depth=1 https://android.googlesource.com/kernel/common common

# Prepare patches & module lists
sudo mkdir -p common/patches
sudo cp ../patches/*.patch common/patches/
sudo cp ../modules.vendor_blocklist common/
sudo cp ../modules.list.msm.parrot common/

# Apply patches
chmod +x scripts/kconfig/apply-kernel-patches.sh
scripts/kconfig/apply-kernel-patches.sh "$PWD" "5.10.209" "common/patches"

# Run compatibility scripts
chmod +x scripts/kconfig/*.sh
./scripts/kconfig/fix-old-kernel-compat.sh
./scripts/kconfig/fix-susfs-compat.sh
./scripts/kconfig/bypass-oem-abi.sh
./scripts/kconfig/setup-bbg.sh

# Merge configs
./scripts/kconfig/merge_config.sh \
  arch/arm64/configs/ksu-nethunter.defconfig \
  build.config.gki_kprobes \
  build.config.aarch64 \
  build.config.gki_kprobes.aarch64 \
  build.config.allmodconfig \
  build.config.allmodconfig.aarch64 \
  build.config.moto \
  build.config.msm.common \
  build.config.msm.gki \
  build.config.common \
  build.config.db845c \
  build.config.msm.parrot \
  arch/arm64/configs/vendor/parrot_GKI.config \
  arch/arm64/configs/vendor/ext_config/debug-parrot-genevn.config \
  arch/arm64/configs/vendor/ext_config/moto-parrot-gki.config \
  arch/arm64/configs/vendor/ext_config/debug-parrot.config \
  arch/arm64/configs/vendor/ext_config/moto-parrot.config \
  arch/arm64/configs/vendor/ext_config/moto-parrot-genevn.config
cp .config out/

# Apply feature toggles
[[ "$ADD_SUSFS" == "true" ]] && scripts/kconfig/merge_config.sh .config arch/arm64/configs/vendor/ext_config/susfs.config
[[ "$ADD_ZEROMOUNT" == "true" ]] && scripts/kconfig/merge_config.sh .config arch/arm64/configs/vendor/ext_config/zeromount.config
[[ "$ADD_ZRAM" == "true" ]] && scripts/kconfig/merge_config.sh .config arch/arm64/configs/vendor/ext_config/zram.config
[[ "$ADD_BBG" == "true" ]] && scripts/kconfig/merge_config.sh .config arch/arm64/configs/vendor/ext_config/bbg.config
[[ "$ADD_OVERLAYFS" == "true" ]] && scripts/kconfig/merge_config.sh .config arch/arm64/configs/vendor/ext_config/overlayfs.config
[[ "$ADD_KPM" == "true" ]] && scripts/kconfig/merge_config.sh .config arch/arm64/configs/vendor/ext_config/kpm.config

case "$KSU_VARIANT" in
  "KernelSU-Next") scripts/kconfig/merge_config.sh .config arch/arm64/configs/vendor/ext_config/ksu-next.config ;;
  "SukiSU") scripts/kconfig/merge_config.sh .config arch/arm64/configs/vendor/ext_config/sukisu.config ;;
  "ReSukiSU") scripts/kconfig/merge_config.sh .config arch/arm64/configs/vendor/ext_config/resukisu.config ;;
  "WKSU") scripts/kconfig/merge_config.sh .config arch/arm64/configs/vendor/ext_config/wksu.config ;;
esac
cp .config out/

# Build kernel
export ARCH=arm64
export SUBARCH=arm64
export CROSS_COMPILE="aarch64-linux-gnu-"
export LLVM=1
export LLVM_IAS=1
export CC="clang-12"
export LD="ld.lld-12"
export AR="llvm-ar-12"
export NM="llvm-nm-12"
export OBJCOPY="llvm-objcopy-12"
export OBJDUMP="llvm-objdump-12"
export STRIP="llvm-strip-12"
make O=out ARCH=arm64 CC=clang-12 LD=ld.lld-12 CLANG_TRIPLE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1 Image.gz -j$(nproc) || exit 1

# Package kernel
cd packages
./build_boot_image.sh ../out/arch/arm64/boot/Image.gz
cp ../out/boot.img ../../Genevn-Kernel-Flashable.img
cd ../..

echo "Build complete! Output: Genevn-Kernel-Flashable.img"
