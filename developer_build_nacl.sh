#!/bin/bash

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

source set_swdev.sh

./qtbase/nacl-configure ${platform}_pnacl release 64 x86_64 -developer-build -openssl-linked -I$SWDEV/stacks/texas_videoconf/third_party/third_party/openssl/openssl/include

make -j6 module-qtbase module-qtdeclarative module-qtmultimedia module-qt3d module-qtsvg module-qtxmlpatterns module-qtquickcontrols module-qtgraphicaleffects
