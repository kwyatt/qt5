#!/bin/bash

set -e

version=`$TEAMCITY_GIT_PATH rev-parse HEAD`
install_dir=$PWD/$version

source st_set_swdev.sh

./configure -prefix $install_dir -release -opensource -confirm-license -shared -platform macx-clang -I "$SW_DEV/stacks/texas_videoconf/third_party/third_party/openssl/openssl/include" -nomake examples -nomake tests -no-compile-examples -no-feature-bearermanagement

make -j8

python ./st_gen_and_upload_symbols.py --os macosx

make install

tar cvzf qt-$version-osx.tar.gz ./$version

# Delete the version folder, since the way teamcity cleans things having a folder that's
# also a revision is bad
rm -rf ./$version
