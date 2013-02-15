#!/bin/bash

set -e

version=`$TEAMCITY_GIT_PATH rev-parse HEAD`
install_dir=$PWD/$version

OSX_SDK=osxsdk-10.6-osx.tar.gz
curl -o $OSX_SDK http://repo.suitabletech.com/downloads/osxsdk/$OSX_SDK
tar xvzf $OSX_SDK
./configure -prefix $install_dir -release -opensource -confirm-license -shared -nomake examples -nomake demos -nomake docs -no-c++11 -platform macx-g++ -sdk $PWD/10.6

make -j8
make install

tar cvzf qt-$version-osx.tar.gz ./$version

# Delete the version folder, since the way teamcity cleans things having a folder that's
# also a revision is bad
rm -rf ./$version
