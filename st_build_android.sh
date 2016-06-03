#!/bin/bash

set -e

BUILD_DIRECTORY=`pwd -P`
echo "Build directory: $BUILD_DIRECTORY"

cd `dirname "$0"`
SOURCE_DIRECTORY=`pwd -P`
cd "$BUILD_DIRECTORY"
echo "Source directory: $SOURCE_DIRECTORY"

os=$1
echo "OS: $os"

arch=${2:-armeabi-v7a}
echo "Architecture: $arch"

cd "$SOURCE_DIRECTORY"
version=`"$TEAMCITY_GIT_PATH" rev-parse HEAD`
cd "$BUILD_DIRECTORY"
if [ -z "$version" ]; then
  echo "Error: could not get the revision."
  exit 1;
fi
echo "Revision: $version"

source "$SOURCE_DIRECTORY/st_set_swdev.sh"
echo "SW-DEV: $SW_DEV"

"$SOURCE_DIRECTORY/configure" -prefix "$BUILD_DIRECTORY/$version" -release -commercial -confirm-license -shared -xplatform android-g++ -D QT_OPENSSL_COMBINED=1 -I "$SW_DEV/stacks/texas_videoconf/third_party/third_party/openssl/openssl/include" -openssl -nomake examples -nomake tests -skip qttranslations -skip qtwebkit -no-compile-examples -no-dbus -no-feature-bearermanagement -no-icu -no-warnings-are-errors -android-sdk $ANDROID_SDK_ROOT -android-ndk $ANDROID_NDK_ROOT -android-ndk-host $ANDROID_NDK_HOST -android-arch $arch -android-toolchain-version 4.8
echo "Configuration complete."

make -j8
echo "Make complete."

# Symbol dumping only works on Linux, which has
# the right elf headers
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
  python "$SOURCE_DIRECTORY/st_gen_and_upload_symbols.py" --os android --swdev "$SW_DEV"
  echo "Symbol upload complete."
else
  echo "No symbol upload for non-Linux platform: $unamestr"
fi

make install
echo "Installation to staging directory complete."

tar cvzf qt-$version-$os-android-$arch.tar.gz ./$version
echo "Tarball generation complete."

# Delete the version folder, since the way teamcity cleans things having a folder that's
# also a revision is bad
rm -rf ./$version
echo "Staging directory deletion complete."
