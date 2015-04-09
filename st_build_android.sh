#!/bin/bash

set -e
git_bin=${TEAMCITY_GIT_PATH:-"git"}
version=`$git_bin rev-parse HEAD`
install_dir=$PWD/$version
os=$1
arch=${2:-armeabi-v7a}

./configure -prefix $install_dir -release -opensource -confirm-license -shared -xplatform android-g++ -nomake tests -nomake examples -android-arch $arch -android-ndk $ANDROID_NDK_ROOT -android-sdk $ANDROID_SDK_ROOT -android-ndk-host $ANDROID_NDK_HOST -android-toolchain-version 4.8 -skip qttranslations -skip qtwebkit -no-warnings-are-errors -no-feature-bearermanagement -no-dbus

make -j8

# Symbol dumping only works on Linux, which has
# the right elf headers
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
  python ./st_gen_and_upload_symbols.py --os android
fi

make install

tar cvzf qt-$version-$os-android-$arch.tar.gz ./$version
# Delete the version folder, since the way teamcity cleans things having a folder that's
# also a revision is bad
rm -rf ./$version
