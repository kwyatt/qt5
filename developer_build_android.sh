#!/bin/bash

arch=${1:-armeabi-v7a}

source set_swdev.sh

#./configure -developer-build -release -opensource -confirm-license -shared -xplatform android-g++ -nomake tests -nomake examples -android-arch $arch -android-ndk $ANDROID_NDK_ROOT -android-sdk $ANDROID_SDK_ROOT -android-ndk-host $ANDROID_NDK_HOST -android-toolchain-version 4.8 -skip qttranslations -skip qtwebkit -no-warnings-are-errors -no-feature-bearermanagement -no-compile-examples -openssl -I$SWDEV/stacks/texas_videoconf/third_party/third_party/openssl/openssl/include

make -j8
