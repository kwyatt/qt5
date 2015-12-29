#!/bin/bash

set -e

version=`git rev-parse HEAD`
install_dir=$PWD/$version
# Need both for OSX (os=osx, plat=mac)
os=$1
plat=$2

source set_swdev.sh

./qtbase/nacl-configure ${plat}_pnacl release 64 x86_64 -prefix $install_dir -openssl-linked -I$SW_DEV/stacks/texas_videoconf/third_party/third_party/openssl/openssl/include
make -j6 module-qtbase module-qtdeclarative module-qtmultimedia module-qt3d module-qtsvg module-qtxmlpatterns module-qtquickcontrols module-qtgraphicaleffects
make module-qtbase-install_subtargets module-qtdeclarative-install_subtargets module-qtmultimedia-install_subtargets module-qt3d-install_subtargets module-qtsvg-install_subtargets module-qtxmlpatterns-install_subtargets module-qtquickcontrols-install_subtargets module-qtgraphicaleffects-install_subtargets

tar cvzf qt-$version-$os-nacl.tar.gz ./$version

# Delete the version folder, since the way teamcity cleans things having a folder that's
# also a revision is bad
rm -rf ./$version
