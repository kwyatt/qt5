#!/bin/bash

set -e

BUILD_DIRECTORY=`pwd -P`
echo "Build directory: $BUILD_DIRECTORY"

cd `dirname "$0"`
SOURCE_DIRECTORY=`pwd -P`
cd "$BUILD_DIRECTORY"
echo "Source directory: $SOURCE_DIRECTORY"

# Either debug (default) or release.
# Note that debug-and-release causes problems:
# - With -no-framework, both debug and release libraries get linked into the application.
# - Without -no-framework, there are build problems with webkit.
config=${1:-debug}
echo "Configuration: $config"

"$SOURCE_DIRECTORY/configure" -$config -force-debug-info -developer-build -opensource -confirm-license -shared -platform macx-clang -no-openssl -nomake examples -nomake tests -no-compile-examples -no-icu -no-pch -no-feature-bearermanagement -no-framework -securetransport
echo "Configuration complete."

make -j8
echo "Make complete."
