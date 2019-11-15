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
build 16 "armeabi-v7a"
build 16 "x86_64"
build 16 "x86"


mkdir -p $ROOT/include
mkdir -p $ROOT/lib
mkdir -p $ROOT/lib/arm64-v8a
mkdir -p $ROOT/lib/armeabi-v8a
mkdir -p $ROOT/lib/x86_64
mkdir -p $ROOT/lib/x86

cp -vrf $ROOT/output/arm64-v8a/include/event2   $ROOT/include/
cp -vrf $ROOT/output/arm64-v8a/lib/libevent.a   $ROOT/lib/arm64-v8a/
cp -vrf $ROOT/output/armeabi-v7a/lib/libevent.a $ROOT/lib/armeabi-v7a/
cp -vrf $ROOT/output/x86_64/lib/libevent.a      $ROOT/lib/x86_64/
cp -vrf $ROOT/output/x86/lib/libevent.a         $ROOT/lib/x86/

rm -rf $ROOT/output/
