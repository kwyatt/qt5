#!/bin/bash

set -e

BUILD_DIRECTORY=`pwd -P`
echo "Build directory: $BUILD_DIRECTORY"

cd `dirname "$0"`
SOURCE_DIRECTORY=`pwd -P`
cd "$BUILD_DIRECTORY"
echo "Source directory: $SOURCE_DIRECTORY"

# Need for OSX (os=osx)
os=$1
echo "OS: $os"

# Need for OSX (plat=mac)
plat=$2
echo "Platform: $plat"

cd "$SOURCE_DIRECTORY"
version=`"$TEAMCITY_GIT_PATH" rev-parse HEAD`
cd "$BUILD_DIRECTORY"
if [ -z "$version" ]; then
  echo "Error: could not get the revision."
  exit 1;
fi
echo "Revision: $version"

source "$SOURCE_DIRECTORY/st_set_swdev.sh"
echo "SW-DEV: $SW_DEV"

"$SOURCE_DIRECTORY/qtbase/nacl-configure" ${plat}_pnacl release 64 x86_64 -prefix "$BUILD_DIRECTORY/$version" -commercial -I "$SW_DEV/stacks/texas_videoconf/third_party/third_party/openssl/openssl/include" -openssl-linked
echo "Configuration complete."

#make -j6 module-qtbase module-qtdeclarative module-qtmultimedia module-qt3d module-qtsvg module-qtxmlpatterns module-qtquickcontrols module-qtgraphicaleffects
make -j6 module-qtbase module-qtdeclarative module-qtmultimedia module-qtsvg module-qtxmlpatterns module-qtquickcontrols module-qtgraphicaleffects
echo "Make complete."

make module-qtbase-install_subtargets module-qtdeclarative-install_subtargets module-qtmultimedia-install_subtargets module-qt3d-install_subtargets module-qtsvg-install_subtargets module-qtxmlpatterns-install_subtargets module-qtquickcontrols-install_subtargets module-qtgraphicaleffects-install_subtargets
echo "Installation to staging directory complete."

tar cvzf qt-$version-$os-nacl.tar.gz ./$version
echo "Tarball generation complete."

# Delete the version folder, since the way teamcity cleans things having a folder that's
# also a revision is bad
rm -rf ./$version
echo "Staging directory deletion complete."
