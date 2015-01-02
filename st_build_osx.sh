#!/bin/bash

set -e

version=`$TEAMCITY_GIT_PATH rev-parse HEAD`
install_dir=$PWD/$version

./configure -prefix $install_dir -release -opensource -confirm-license -shared -nomake examples -platform macx-clang -no-feature-bearermanagement

make -j8

python ./st_gen_and_upload_symbols.py --os macosx

make install

tar cvzf qt-$version-osx.tar.gz ./$version

# Delete the version folder, since the way teamcity cleans things having a folder that's
# also a revision is bad
rm -rf ./$version
