#!/bin/bash

set -e

bits=$1
arch=$2
version=`git rev-parse HEAD`
install_dir=$PWD/$version

./configure -prefix $install_dir -release -platform linux-g++-$bits -opensource -confirm-license -shared -nomake examples -nomake demos -nomake docs -xkb -xinput -xrender -xrandr -xfixes -xcursor -xinerama -xshape -opengl -fontconfig -qt-xcb

make -j8
make install

tar cvzf qt-$version-linux-$arch.tar.gz ./$version

# Delete the version folder, since the way teamcity cleans things having a folder that's
# also a revision is bad
rm -rf ./$version