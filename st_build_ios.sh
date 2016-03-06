#!/bin/bash

set -e

version=`"$TEAMCITY_GIT_PATH" rev-parse HEAD`
install_dir=$PWD/$version

source st_set_swdev.sh

./configure -prefix $install_dir -debug-and-release -commercial -confirm-license -xplatform macx-ios-clang -no-openssl -nomake examples -nomake tests -skip qttranslations -skip qtwebkit -no-compile-examples -no-warnings-are-errors -no-feature-bearermanagement -securetransport

make -j8

# Static build; don't need symbols until after link
# python ./st_gen_and_upload_symbols.py --os ios --swdev "$SW_DEV"

make install

tar cvzf qt-$version-ios.tar.gz ./$version

# Delete the version folder, since the way teamcity cleans things having a folder that's
# also a revision is bad
rm -rf ./$version
