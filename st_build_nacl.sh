#!/bin/bash

function check_call() {
  if [ -z "$1" ]; then
    echo "Please pass a command to check_call"
    exit 1
  fi

  echo "Running $@"
  $@
  exit_code=$?
  if [ "$exit_code" -ne "0" ]; then
    echo "Command: $1 failed with code $exit_code"
    exit $exit_code
  else
    return $exit_code
  fi
}

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

check_call "$SOURCE_DIRECTORY/qtbase/nacl-configure" ${plat}_pnacl release x86_64_translated -prefix "$BUILD_DIRECTORY/$version" -commercial -I "$SW_DEV/stacks/texas_videoconf/third_party/third_party/openssl/openssl/include" -openssl-linked -nacl-secondary-thread
echo "Configuration complete."

check_call make -j6 module-qtbase module-qtdeclarative module-qtmultimedia module-qtsvg module-qtxmlpatterns module-qtquickcontrols module-qtgraphicaleffects
echo "Make complete."

check_call make module-qtbase-install_subtargets module-qtdeclarative-install_subtargets module-qtmultimedia-install_subtargets module-qtsvg-install_subtargets module-qtxmlpatterns-install_subtargets module-qtquickcontrols-install_subtargets module-qtgraphicaleffects-install_subtargets
echo "Installation to staging directory complete."

check_call tar cvzf qt-$version-$os-nacl.tar.gz ./$version
echo "Tarball generation complete."

# Delete the version folder, since the way teamcity cleans things having a folder that's
# also a revision is bad
rm -rf ./$version
echo "Staging directory deletion complete."
