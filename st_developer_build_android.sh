#!/bin/bash

set -e

if [ ! -d "$QT_BUILD_SWDEV" ]; then
  echo "Please set QT_BUILD_SWDEV to a valid sw-dev directory path; $QT_BUILD_SWDEV does not exist"
  exit 1;
fi

BUILD_DIRECTORY=`pwd -P`
echo "Build directory: $BUILD_DIRECTORY"

cd `dirname "$0"`
SOURCE_DIRECTORY=`pwd -P`
cd "$BUILD_DIRECTORY"
echo "Source directory: $SOURCE_DIRECTORY"

arch=${1:-armeabi-v7a}
echo "Architecture: $arch"

"$SOURCE_DIRECTORY/configure" -release -force-debug-info -developer-build -opensource -confirm-license -shared -xplatform android-g++ -D QT_OPENSSL_COMBINED=1 -I "$QT_BUILD_SWDEV/stacks/texas_videoconf/third_party/third_party/openssl/openssl/include" -openssl -nomake examples -nomake tests -skip qttranslations -no-compile-examples -no-icu -no-dbus -no-feature-bearermanagement -no-warnings-are-errors -android-sdk $ANDROID_SDK_ROOT -android-ndk $ANDROID_NDK_ROOT -android-ndk-host $ANDROID_NDK_HOST -android-arch $arch -android-toolchain-version 4.8 -no-android-style-assets
echo "Configuration complete."

make -j8
echo "Make complete."
