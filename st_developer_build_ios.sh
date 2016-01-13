#!/bin/bash

set -e

BUILD_DIRECTORY=`pwd -P`
cd `dirname "$0"`
SOURCE_DIRECTORY=`pwd -P`
cd "$BUILD_DIRECTORY"

source "$SOURCE_DIRECTORY/st_set_swdev.sh"

# Both debug and release libraries are needed.
# TODO: Remove OpenSSL in favor of securetransport starting with Qt 5.5?
#"$SOURCE_DIRECTORY/configure" -debug-and-release -force-debug-info -developer-build -opensource -confirm-license -xplatform macx-ios-clang -no-openssl -nomake examples -nomake tests -skip qttranslations -skip qtwebkit -no-warnings-are-errors -no-feature-bearermanagement -securetransport
OPENSSL_LIBS=" " "$SOURCE_DIRECTORY/configure" -debug-and-release -force-debug-info -developer-build -opensource -confirm-license -xplatform macx-ios-clang -I "$SW_DEV/stacks/texas_videoconf/third_party/third_party/openssl/openssl/include" -openssl-linked -nomake examples -nomake tests -skip qttranslations -skip qtwebkit -no-compile-examples -no-feature-bearermanagement -no-warnings-are-errors

make -j8
