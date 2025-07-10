# android_kernel_sweet2

## Prepare environment

Install this packages:
```
bc cpio ccache gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu build-essential flex bison libelf-dev libssl-dev python3 lld curl git
```

## Prepare toolchains

```shell
bash prebuilts/fetch.sh
```

## Setup env variables

```shell
export ARCH=arm64
export PATH="${PWD}/prebuilts/clang/bin:${PWD}/prebuilts/gcc64/bin:${PWD}/prebuilts/gcc32/bin:${PATH}"
export KBUILD_BUILD_USER=build-user
export KBUILD_BUILD_HOST=build-host
export KBUILD_COMPILER_STRING="${PWD}/clang"
export LLVM=1 
export LLVM_IAS=1
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-android-
export CROSS_COMPILE_COMPAT=arm-linux-androideabi-
```

## Make defconfig

```shell
make O=out sweet_defconfig
```

## Build kernel

```shell
make -j$(nproc --all) O=out CC=clang
```

If build successful, grab kernel files:

- `out/arch/arm64/boot/Image.gz`
- `out/arch/arm64/boot/dtb.img`
- `out/arch/arm64/boot/dtbo.img`
