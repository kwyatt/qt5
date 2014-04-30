#!/bin/bash

set -e
version=`$TEAMCITY_GIT_PATH rev-parse HEAD`
install_dir=$PWD/$version-android
os=$1
arch=${2:-armeabi-v7a}

./configure -prefix $install_dir -release -opensource -confirm-license -shared -xplatform android-g++ -nomake tests -nomake examples -android-arch $arch -android-ndk $ANDROID_NDK_ROOT -android-sdk $ANDROID_SDK_ROOT -android-ndk-host $ANDROID_NDK_HOST -android-toolchain-version 4.8 -skip qttranslations -skip qtwebkit -no-warnings-are-errors

make -j8
# TODO generate and upload symbols

make install

tar cvzf qt-$version-$os-android-$arch.tar.gz $install_dir
# Delete the version folder, since the way teamcity cleans things having a folder that's
# also a revision is bad
rm -rf $install_dir
