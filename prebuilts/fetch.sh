#!/bin/bash

SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

fetch_clang() {
    FETCH_DIR=$SCRIPT_DIR/clang
    URL="https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r547379.tar.gz"

    if [ ! -d $FETCH_DIR ]; then
        mkdir -p $FETCH_DIR
    fi

    wget -qqO- "$URL" | tar xz -C "$FETCH_DIR"
}

fetch_gcc64() {
    FETCH_DIR=$SCRIPT_DIR/gcc64
    URL="https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9/archive/refs/heads/lineage-19.1.tar.gz"

    if [ ! -d $FETCH_DIR ]; then
        mkdir -p $FETCH_DIR
    fi

    wget -qqO- "$URL" | tar xz --strip-components=1 -C "$FETCH_DIR"
}

fetch_gcc32() {
    FETCH_DIR=$SCRIPT_DIR/gcc32
    URL="https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9/archive/refs/heads/lineage-19.1.tar.gz"

    if [ ! -d $FETCH_DIR ]; then
        mkdir -p $FETCH_DIR
    fi

    wget -qqO- "$URL" | tar xz --strip-components=1 -C "$FETCH_DIR"
}

if [ ! -d $SCRIPT_DIR/clang ]; then
  fetch_clang
fi

if [ ! -d $SCRIPT_DIR/gcc32 ]; then
  fetch_gcc32
fi

if [ ! -d $SCRIPT_DIR/gcc64 ]; then
  fetch_gcc64
fi
