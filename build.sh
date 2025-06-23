#!/bin/bash

set -e

# Install required packages
sudo apt-get update
sudo apt-get install -y bc cpio ccache gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu build-essential flex bison libelf-dev libssl-dev python3 lld curl git

# Ask for AOSP or OEM
read -p "Enter build type (aosp/oem): " buildtype
buildtype_lower=$(echo "$buildtype" | tr '[:upper:]' '[:lower:]')

# Set zip name
if [[ "$buildtype_lower" == "aosp" ]]; then
    ZIPNAME="AOSP-MeMeDo-sweet_k6a-$(date '+%Y%m%d').zip"
else
    ZIPNAME="MIUI-OOS-MeMeDo-sweet_k6a-$(date '+%Y%m%d').zip"
fi

# Download Clang and GCC toolchains
if [ ! -d clang ]; then
    mkdir clang
    curl -LO https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r547379.tar.gz
    tar -xf clang-r547379.tar.gz -C clang/
    rm clang-r547379.tar.gz
fi

if [ ! -d gcc64 ]; then
    git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 gcc64
fi

if [ ! -d gcc32 ]; then
    git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 gcc32
fi

# Setup environment
export ARCH=arm64
export PATH="${PWD}/clang/bin:${PWD}/gcc64/bin:${PWD}/gcc32/bin:${PATH}"
export KBUILD_BUILD_USER=build-user
export KBUILD_BUILD_HOST=build-host
export KBUILD_COMPILER_STRING="${PWD}/clang"
export LLVM=1 
export LLVM_IAS=1
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-android-
export CROSS_COMPILE_COMPAT=arm-linux-androideabi-

# Build directory

# Kernel compilation
make O=out sweet_defconfig
make -j$(nproc --all) O=out CC=clang 2>&1 | tee build.log

# Save config for reference
cp out/.config out/sweet_defconfig.txt

# Check output
KERNEL_IMG="out/arch/arm64/boot/Image.gz"
DTBO_IMG="out/arch/arm64/boot/dtbo.img"
DTB_IMG="out/arch/arm64/boot/dtb.img"

if [[ ! -f "$KERNEL_IMG" || ! -f "$DTBO_IMG" || ! -f "$DTB_IMG" ]]; then
    echo -e "\n❌ Build failed. Missing output image(s)."
    exit 1
fi

# Prepare AnyKernel3
rm -rf AnyKernel3
git clone https://github.com/MiDoNaSR545/AnyKernel3

cp $KERNEL_IMG AnyKernel3
cp $DTBO_IMG AnyKernel3
cp $DTB_IMG AnyKernel3

cd AnyKernel3
zip -r9 "../$ZIPNAME" * -x .git README.md
cd ..

echo -e "\n✅ Kernel built and packed as: $ZIPNAME"

# Upload the file using transfer.sh (25 MB+ limit)
if command -v curl &> /dev/null; then
    echo -e "\n📤 Uploading via transfer.sh..."
    curl -u ":$PIXELDRAIN_API_KEY" -F "file=@$ZIPNAME" https://pixeldrain.com/api/file
else
    echo -e "\n⚠️ curl not installed or transfer.sh unavailable. File not uploaded."
fi