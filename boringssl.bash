#!/bin/bash


if [[ "$NDK_HOME" = "" ]]; then
    echo "NDK_HOME not defined."
    exit 1
fi


ROOT=`pwd`


mkdir -p $ROOT/include
mkdir -p $ROOT/lib
mkdir -p $ROOT/build


rm -rf $ROOT/build/boringssl
tar -xf boringssl.tar.gz -C $ROOT/build/
cd $ROOT/build/boringssl


# install headers
cp -rf include/* $ROOT/include/


function build() {
    API=$1
    ABI=$2

    BUILD_DIR="cmake-build-$ABI"
    mkdir -p $BUILD_DIR

    pushd $BUILD_DIR
    cmake .. \
        -DANDROID_ABI=$ABI \
        -DCMAKE_TOOLCHAIN_FILE=${NDK_HOME}/build/cmake/android.toolchain.cmake \
        -DANDROID_NATIVE_API_LEVEL=$API \
        -DCMAKE_BUILD_TYPE=Release \
        -GNinja
    cmake --build . --config Release
    popd

    mkdir -p "$ROOT/lib/$ABI"
    cp "$BUILD_DIR/ssl/libssl.a"  "$ROOT/lib/$ABI/libssl.a"
    cp "$BUILD_DIR/crypto/libcrypto.a"  "$ROOT/lib/$ABI/libcrypto.a"
}


build 21 "arm64-v8a"
build 16 "armeabi"
build 16 "armeabi-v7a"
build 16 "x86_64"
build 16 "x86"

