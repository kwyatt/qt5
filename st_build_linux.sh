#!/bin/bash

set -e

echo "===== Parsing arguments..."
bits=$1
if [[ -z "$bits" ]]; then
  if [[ "$(uname -m)" == "x86_64" ]]; then
    bits="64"
  else
    bits="32"
  fi
  echo "Bits: $bits (from build machine)."
else
  echo "Bits: $bits (user specified)."
fi

arch=$2
if [[ -z "$arch" ]]; then
  arch=$(uname -m)
  echo "Architecture: $arch (from build machine)"
else
  echo "Architecture: $arch (user specified)"
fi

version=`"$TEAMCITY_GIT_PATH" rev-parse HEAD`
echo "Version: $version"

source st_set_swdev.sh
echo "SW-DEV: $SW_DEV"

install_dir=$PWD/$version
echo "Install directory: $install_dir"
echo "===== Parsed arguments."

echo "===== Configuring Qt..."
./configure -prefix $install_dir -release -opensource -confirm-license -shared -platform linux-g++-$bits -nomake examples -nomake tests -no-compile-examples -xkb -xinput -xrender -xrandr -xfixes -xcursor -xinerama -xshape -opengl -fontconfig -qt-xcb -gtkstyle -qt-libjpeg -no-feature-bearermanagement -no-dbus
echo "===== Configured Qt."

echo "===== Making Qt..."
make -j8
echo "===== Made Qt."

echo "===== Uploading symbols..."
python ./st_gen_and_upload_symbols.py --os linux --swdev "$SW_DEV"
echo "===== Uploading symbols."

echo "===== Installing Qt to staging directory..."
make install
echo "===== Installed Qt to staging directory."

echo "===== Removing old libicu dependencies..."
for f in $version/lib/libicu*; do
  echo $f
  rm -f $version/lib/libicu*
done
echo "===== Removed old libicu dependencies."

echo "===== Scanning libicu dependencies..."
iculibs=
for f in $version/lib/*; do
  if [[ -f $f && ! -h $f ]]; then
    iculibs+="$(ldd $f 2> /dev/null | sed -n 's/^[[:space:]]*libicu[[:alnum:]]\+\.so\.[0-9]\+[[:space:]]*=>[[:space:]]*\(.*\.so\)[.0-9]*[[:space:]]*([[:alnum:]]\+)[[:space:]]*$/\1/p') "
  fi
done
iculibs=$(echo -e $iculibs | tr " " "\n" | sort -u)
echo -e "$iculibs"
echo "===== Scanned libicu dependencies."

echo "===== Copying libicu dependencies..."
for f in $iculibs; do
  rsync -avz $f* $version/lib;
done
echo "===== Copied libicu dependencies."

echo "===== Generating tarball..."
tar cvzf qt-$version-linux-$arch.tar.gz ./$version
echo "===== Generated tarball."

# Delete the version folder, since the way teamcity cleans things having a folder that's
# also a revision is bad
echo "===== Deleting intermediate folder..."
rm -rf ./$version
echo "===== Deleted intermediate folder."
