#!/bin/bash

set -e

if [ ! -d "$QT_BUILD_SWDEV" ]; then
  echo "Please set QT_BUILD_SWDEV to a valid sw-dev directory path; $QT_BUILD_SWDEV does not exist"
  exit 1;
fi

BUILD_DIRECTORY=`pwd -P`
echo "Build directory: $BUILD_DIRECTORY"

cd `dirname "$0"`
SOURCE_DIRECTORY=`pwd -P`
cd "$BUILD_DIRECTORY"
echo "Source directory: $SOURCE_DIRECTORY"

unamestr=`uname`
platform='unknown'
if [[ "$unamestr" == 'Darwin' ]]; then
  platform='mac'
elif [[ "$unamestr" == 'Linux' ]]; then
  platform='linux'
fi
echo "Platform: $platform"
if [[ "$platform" == 'unknown' ]]; then
  echo "Unsupported platform"
  exit 1
fi

"$SOURCE_DIRECTORY/qtbase/nacl-configure" ${platform}_pnacl release 64 x86_64 -force-debug-info -developer-build -opensource -I "$QT_BUILD_SWDEV/stacks/texas_videoconf/third_party/third_party/openssl/openssl/include" -openssl-linked
echo "Configuration complete."

make -j6 module-qtbase module-qtdeclarative module-qtmultimedia module-qtsvg module-qtxmlpatterns module-qtquickcontrols module-qtgraphicaleffects
echo "Make complete."
