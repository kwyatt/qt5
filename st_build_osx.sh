#!/bin/bash

set -e

version=`$TEAMCITY_GIT_PATH rev-parse HEAD`
install_dir=$PWD/$version

# See NCA-6261 and NCA-5990 for -no-harfbuzz rationale.
# FIXME: Revisit when updating Qt to 5.4.
./configure -prefix $install_dir -release -opensource -confirm-license -shared -nomake examples -no-c++11 -platform macx-clang -no-feature-bearermanagement -no-harfbuzz

make -j8

python ./st_gen_and_upload_symbols.py --os macosx

make install

tar cvzf qt-$version-osx.tar.gz ./$version

# Delete the version folder, since the way teamcity cleans things having a folder that's
# also a revision is bad
rm -rf ./$version
