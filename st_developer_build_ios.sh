#!/bin/bash

set -e

BUILD_DIRECTORY=`pwd -P`
echo "Build directory: $BUILD_DIRECTORY"

cd `dirname "$0"`
SOURCE_DIRECTORY=`pwd -P`
cd "$BUILD_DIRECTORY"
echo "Source directory: $SOURCE_DIRECTORY"

# Both debug and release libraries are needed.
"$SOURCE_DIRECTORY/configure" -debug-and-release -force-debug-info -developer-build -opensource -confirm-license -xplatform macx-ios-clang -no-openssl -nomake examples -nomake tests -skip qttranslations -skip qtwebkit -no-compile-examples -no-icu -no-feature-bearermanagement -no-warnings-are-errors -securetransport
echo "Configuration complete."

make -j8
echo "Make complete."
