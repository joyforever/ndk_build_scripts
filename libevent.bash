#!/bin/bash


if [[ "$NDK_HOME" = "" ]]; then
    echo "NDK_HOME not defined."
    exit 1
fi


ROOT=`pwd`


mkdir -p $ROOT/build
rm -rf $ROOT/build/libevent-2.1.11-stable
tar -xf libevent-2.1.11-stable.tar.gz -C $ROOT/build/
cd $ROOT/build/libevent-2.1.11-stable


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
        -DEVENT__LIBRARY_TYPE=STATIC \
        -DEVENT__DISABLE_OPENSSL=ON \
        -DEVENT__DISABLE_BENCHMARK=ON \
        -DEVENT__DISABLE_TESTS=ON \
        -DEVENT__DISABLE_REGRESS=ON \
        -DEVENT__DISABLE_SAMPLES=ON \
        -DEVENT__DISABLE_DEBUG_MODE=ON \
        -DCMAKE_INSTALL_PREFIX=$ROOT/output/$ABI \
        -GNinja
    ninja -j4
    ninja install
    popd
}


build 21 "arm64-v8a"
build 16 "armeabi"
build 16 "armeabi-v7a"
build 16 "x86_64"
build 16 "x86"

