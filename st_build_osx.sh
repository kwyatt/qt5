#!/bin/bash

set -e

BUILD_DIRECTORY=`pwd -P`
echo "Build directory: $BUILD_DIRECTORY"

cd `dirname "$0"`
SOURCE_DIRECTORY=`pwd -P`
cd "$BUILD_DIRECTORY"
echo "Source directory: $SOURCE_DIRECTORY"

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

"$SOURCE_DIRECTORY/configure" -prefix "$BUILD_DIRECTORY/$version" -release -opensource -confirm-license -shared -platform macx-clang -no-openssl -nomake examples -nomake tests -no-compile-examples -no-icu -no-feature-bearermanagement -securetransport
echo "Configuration complete."

make -j8
echo "Make complete."

python "$SOURCE_DIRECTORY/st_gen_and_upload_symbols.py" --os macosx --swdev "$SW_DEV"
echo "Symbol upload complete."

make install
echo "Installation to staging directory complete."

tar cvzf qt-$version-osx.tar.gz ./$version
echo "Tarball generation complete."

# Delete the version folder, since the way teamcity cleans things having a folder that's
# also a revision is bad
rm -rf ./$version
echo "Staging directory deletion complete."
