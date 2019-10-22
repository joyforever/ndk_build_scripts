#!/bin/bash


if [[ "$NDK_ROOT" = "" ]]; then
    echo "NDK_ROOT not defined."
    exit 1
fi


ROOT=`pwd`


mkdir -p $ROOT/include
mkdir -p $ROOT/lib
mkdir -p $ROOT/build


rm -rf $ROOT/build/protobuf-3.6.1
tar -xf protobuf-cpp-3.6.1.tar.gz -C $ROOT/build/
cd $ROOT/build/protobuf-3.6.1


BUILD_ROOT=`pwd`


function build() {
    API=$1
    ABI=$2

    BUILD_DIR="cmake-build-$ABI"
    mkdir -p $BUILD_DIR

    pushd $BUILD_DIR
    cmake ../cmake \
        -Dprotobuf_BUILD_TESTS=OFF \
        -Dprotobuf_BUILD_EXAMPLES=OFF \
        -Dprotobuf_BUILD_PROTOC_BINARIES=OFF \
        -Dprotobuf_WITH_ZLIB_DEFAULT=OFF \
        -DBUILD_SHARED_LIBS=OFF \
        -DANDROID_ABI=$ABI \
        -DCMAKE_TOOLCHAIN_FILE=${NDK_ROOT}/build/cmake/android.toolchain.cmake \
        -DANDROID_NATIVE_API_LEVEL=$API \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=. \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -GNinja
    cmake --build . --config Release
    ninja install
    popd

    mkdir -p "$ROOT/lib/$ABI"
    cp -rf $BUILD_DIR/include/*  "$ROOT/include"
    cp "$BUILD_DIR/lib/libprotobuf-lite.a"  "$ROOT/lib/$ABI/libprotobuf.a"
}


build 21 "arm64-v8a"
build 16 "armeabi"
build 16 "armeabi-v7a"
build 16 "x86_64"
build 16 "x86"

