#!/bin/bash

set -e

BUILD_DIRECTORY=`pwd -P`
cd `dirname "$0"`
SOURCE_DIRECTORY=`pwd -P`
cd "$BUILD_DIRECTORY"

unamestr=`uname`
platform='unknown'
if [[ "$unamestr" == 'Darwin' ]]; then
  platform='mac'
elif [[ "$unamestr" == 'Linux' ]]; then
  platform='linux'
fi
echo "$platform"
if [[ "$platform" == 'unknown' ]]; then
  echo "Unsupported platform"
  exit 1
fi

source "$SOURCE_DIRECTORY/st_set_swdev.sh"

"$SOURCE_DIRECTORY/qtbase/nacl-configure" ${platform}_pnacl release 64 x86_64 -force-debug-info -developer-build -openssl-linked -I "$SW_DEV/stacks/texas_videoconf/third_party/third_party/openssl/openssl/include"

make -j6 module-qtbase module-qtdeclarative module-qtmultimedia module-qt3d module-qtsvg module-qtxmlpatterns module-qtquickcontrols module-qtgraphicaleffects
