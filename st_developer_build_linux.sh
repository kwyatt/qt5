#!/bin/bash

set -e

BUILD_DIRECTORY=`pwd -P`
cd `dirname "$0"`
SOURCE_DIRECTORY=`pwd -P`
cd "$BUILD_DIRECTORY"

bits=${1:-64}

"$SOURCE_DIRECTORY/configure" -release -force-debug-info -developer-build -opensource -confirm-license -shared -platform linux-g++-$bits -qt-libjpeg -qt-xcb -gtkstyle -nomake examples -nomake tests -no-compile-examples -fontconfig -no-dbus -no-feature-bearermanagement -opengl -xkb -xinput -xrender -xrandr -xfixes -xcursor -xinerama -xshape

export SOURCE_ROOT="$SOURCE_DIRECTORY/qtwebkit/Source/WebCore"

make -j8
