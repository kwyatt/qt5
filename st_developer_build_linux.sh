#!/bin/bash

set -e

BUILD_DIRECTORY=`pwd -P`
echo "Build directory: $BUILD_DIRECTORY"

cd `dirname "$0"`
SOURCE_DIRECTORY=`pwd -P`
cd "$BUILD_DIRECTORY"
echo "Source directory: $SOURCE_DIRECTORY"

bits=${1:-64}
echo "Bits: $bits"

"$SOURCE_DIRECTORY/configure" -release -force-debug-info -developer-build -opensource -confirm-license -shared -platform linux-g++-$bits -qt-libjpeg -qt-xcb -gtkstyle -nomake examples -nomake tests -no-compile-examples -fontconfig -no-pch -no-icu -no-dbus -no-feature-bearermanagement -opengl -xkb -xinput -xrender -xrandr -xfixes -xcursor -xinerama -xshape
echo "Configuration complete."

make -j8
echo "Make complete."
