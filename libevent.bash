#!/bin/bash


if [[ "$NDK_ROOT" = "" ]]; then
    echo "NDK_ROOT not defined."
    exit 1
fi


ROOT=`pwd`


mkdir -p $ROOT/build
rm -rf $ROOT/build/libevent-release-2.1.8-stable
tar -xf libevent-release-2.1.8-stable.tar.gz -C $ROOT/build/
cd $ROOT/build/libevent-release-2.1.8-stable


function build() {
    API=$1
    ABI=$2

    BUILD_DIR="cmake-build-$ABI"
    mkdir -p $BUILD_DIR

    pushd $BUILD_DIR
    cmake .. \
        -DANDROID_ABI=$ABI \
        -DCMAKE_TOOLCHAIN_FILE=${NDK_ROOT}/build/cmake/android.toolchain.cmake \
        -DANDROID_NATIVE_API_LEVEL=$API \
        -DCMAKE_BUILD_TYPE=Release \
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


patch -p1 < "$ROOT/libevent.patch"
build 21 "arm64-v8a"
build 16 "armeabi"
build 16 "armeabi-v7a"
build 16 "x86_64"
build 16 "x86"

# 编译过程中可能会出现stdlib.h中的符号冲突，先手动将符号注释，待编译完成后手动恢复即可
#
# android-ndk-r19c/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include/stdlib.h
#128 //uint32_t arc4random(void);
#129 //uint32_t arc4random_uniform(uint32_t __upper_bound);
#130 //void arc4random_buf(void* __buf, size_t __n);
#
# android-ndk-r16b/sysroot/usr/include/stdlib.h
#122 //uint32_t arc4random(void);
#123 //uint32_t arc4random_uniform(uint32_t __upper_bound);
#124 //void arc4random_buf(void* __buf, size_t __n);

