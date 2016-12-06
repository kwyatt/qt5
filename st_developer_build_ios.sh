#!/bin/bash

set -e

BUILD_DIRECTORY=`pwd -P`
echo "Build directory: $BUILD_DIRECTORY"

cd `dirname "$0"`
SOURCE_DIRECTORY=`pwd -P`
cd "$BUILD_DIRECTORY"
echo "Source directory: $SOURCE_DIRECTORY"

# Both debug and release libraries are needed.
# Otherwise, sw-dev CMake fails at qtbase/lib/cmake/Qt5Core/Qt5CoreConfig.cmake:15 with:
# The imported target "Qt5::Core" references the file "lib/libQt5Core_debug.a".
# https://bugreports.qt.io/browse/QTBUG-48348
"$SOURCE_DIRECTORY/configure" -debug-and-release -force-debug-info -developer-build -opensource -confirm-license -xplatform macx-ios-clang -no-openssl -nomake examples -nomake tests -skip qttranslations -no-compile-examples -no-icu -no-feature-bearermanagement -no-warnings-are-errors -securetransport
echo "Configuration complete."

make -j8
echo "Make complete."
