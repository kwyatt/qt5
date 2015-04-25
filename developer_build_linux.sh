#!/bin/bash

set -e

bits=$1
./configure -developer-build -release -platform linux-g++-$bits -opensource -confirm-license -shared -nomake examples -nomake tests -xkb -xinput -xrender -xrandr -xfixes -xcursor -xinerama -xshape -opengl -fontconfig -qt-xcb -gtkstyle -qt-libjpeg -no-feature-bearermanagement -no-compile-examples -no-dbus
make -j8
