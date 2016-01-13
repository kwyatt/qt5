#!/bin/bash

set -e

if [ ! -d "$QT_BUILD_SWDEV" ]; then
  echo "Please set QT_BUILD_SWDEV to a valid sw-dev directory path; $QT_BUILD_SWDEV does not exist"
  exit 1;
fi

BUILD_DIRECTORY=`pwd -P`
cd `dirname "$0"`
SOURCE_DIRECTORY=`pwd -P`
cd "$BUILD_DIRECTORY"

# Both debug and release libraries are needed.
# TODO: Remove OpenSSL in favor of securetransport starting with Qt 5.5?
#"$SOURCE_DIRECTORY/configure" -debug-and-release -force-debug-info -developer-build -opensource -confirm-license -xplatform macx-ios-clang -no-openssl -nomake examples -nomake tests -skip qttranslations -skip qtwebkit -no-warnings-are-errors -no-feature-bearermanagement -securetransport
OPENSSL_LIBS=" " "$SOURCE_DIRECTORY/configure" -debug-and-release -force-debug-info -developer-build -opensource -confirm-license -xplatform macx-ios-clang -I "$QT_BUILD_SWDEV/stacks/texas_videoconf/third_party/third_party/openssl/openssl/include" -openssl-linked -nomake examples -nomake tests -skip qttranslations -skip qtwebkit -no-compile-examples -no-feature-bearermanagement -no-warnings-are-errors

make -j8
