#!/bin/bash

set -e

BUILD_DIRECTORY=`pwd -P`
cd `dirname "$0"`
SOURCE_DIRECTORY=`pwd -P`
cd "$BUILD_DIRECTORY"

arch=${1:-armeabi-v7a}

source "$SOURCE_DIRECTORY/st_set_swdev.sh"

"$SOURCE_DIRECTORY/configure" -release -force-debug-info -developer-build -opensource -confirm-license -shared -xplatform android-g++ -I "$SW_DEV/stacks/texas_videoconf/third_party/third_party/openssl/openssl/include" -openssl -nomake examples -nomake tests -skip qttranslations -skip qtwebkit -no-compile-examples -no-dbus -no-feature-bearermanagement -no-warnings-are-errors -android-sdk $ANDROID_SDK_ROOT -android-ndk $ANDROID_NDK_ROOT -android-ndk-host $ANDROID_NDK_HOST -android-arch $arch -android-toolchain-version 4.8

make -j8
