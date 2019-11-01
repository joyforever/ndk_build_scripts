#!/bin/bash


if [[ "$NDK_HOME" = "" ]]; then
    echo "NDK_HOME not defined."
    exit 1
fi


ROOT=`pwd`


mkdir -p $ROOT/include
mkdir -p $ROOT/lib
mkdir -p $ROOT/build


rm -rf $ROOT/build/curl-7.64.1
tar -xf $ROOT/curl-7.64.1.tar.gz -C $ROOT/build/
cd $ROOT/build/curl-7.64.1


# install headers
mkdir -p $ROOT/include/curl
cp -rf include/curl/*.h $ROOT/include/curl/


function build() {
    API=$1
    ABI=$2

    BUILD_DIR="cmake-build-$ABI"
    mkdir -p $BUILD_DIR

    pushd $BUILD_DIR
    cmake .. \
        -DANDROID_ABI=$ABI \
        -DOPENSSL_INCLUDE_DIR=$ROOT/include \
        -DOPENSSL_CRYPTO_LIBRARY=$ROOT/lib/$ABI/libcrypto.a \
        -DOPENSSL_SSL_LIBRARY=$ROOT/lib/$ABI/libssl.a \
        -DHTTP_ONLY=ON \
        -DCMAKE_USE_LIBSSH2=OFF \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=${NDK_HOME}/build/cmake/android.toolchain.cmake \
        -DANDROID_NATIVE_API_LEVEL=$API \
        -GNinja
    cmake --build . --config Release
    popd

    mkdir -p "$ROOT/lib/$ABI"
    cp "$BUILD_DIR/lib/libcurl.a"  "$ROOT/lib/$ABI/libcurl.a"
}


build 21 "arm64-v8a"
build 16 "armeabi"
build 16 "armeabi-v7a"
build 16 "x86_64"
build 16 "x86"

