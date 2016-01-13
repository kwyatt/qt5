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

# Either debug (default) or release.
# Note that debug-and-release causes problems:
# - With -no-framework, both debug and release libraries get linked into the application.
# - Without -no-framework, there are build problems with webkit.
config=${1:-debug}

"$SOURCE_DIRECTORY/configure" -$config -force-debug-info -developer-build -opensource -confirm-license -shared -platform macx-clang -I "$QT_BUILD_SWDEV/stacks/texas_videoconf/third_party/third_party/openssl/openssl/include" -nomake examples -nomake tests -no-compile-examples -no-pch -no-feature-bearermanagement -no-framework

export SOURCE_ROOT="$SOURCE_DIRECTORY/qtwebkit/Source/WebCore"
make -j8
cd "$BUILD_DIRECTORY/qtwebkit"
make install
cd "$BUILD_DIRECTORY"
