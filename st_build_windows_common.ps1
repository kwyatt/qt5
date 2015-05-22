$osname = $args[0]

# Grab ICU, which is required for building webkit
echo "downloading ICU..."
$webclient = New-Object System.Net.WebClient
$webclient.DownloadFile("http://repo.suitabletech.com/downloads/icu4c-50_1_2-$osname-msvc10.zip", "$(get-location)/icu.zip")

# Unzip icu
echo "unzipping ICU..."
& ./unzip.exe "icu.zip"

$icu_libdir = "$(get-location)\icu\lib"
$icu_bindir = "$(get-location)\icu\bin"
if ($osname -eq "win64")
{
  $icu_libdir = "$(get-location)\icu\lib64"
  $icu_bindir = "$(get-location)\icu\bin64"
}

# Grab OpenSSL, which is required for https support
echo "downloading openssl..."
$webclient.DownloadFile("http://repo.suitabletech.com/downloads/openssl-1.0.1h-$osname.zip", "$(get-location)/openssl.zip")

echo "unzipping openssl..."
& ./unzip.exe openssl.zip

$version = $(git rev-parse HEAD)
echo configuring ...
# We build with -no-icu and then enable it manually for QtWebKit. This means QtCore does not end up
# with an ICU dependency, so we can ship installers without ICU (which is huge)
.\configure.bat -debug-and-release -force-debug-info -opensource -confirm-license -shared -nomake examples -nomake tests -mp -no-icu -angle -openssl-linked OPENSSL_LIBS="-lssleay32 -llibeay32" -prefix "$(get-location)\$version" -I "$(get-location)\icu\include" -L "$icu_libdir" -I "$(get-location)\openssl\include" -L "$(get-location)\openssl\lib" -D QT_NO_BEARERMANAGEMENT

if ($LastExitCode -ne 0) { exit $LastExitCode }

# Setup PATH to include <qtbase>/lib and <icu>/bin, which seems to be necessary for Qt 5.1
$env:PATH += ";$icu_bindir;$(get-location)\qtbase\lib"

echo building...
#nmake (jom is much faster)
& "$(get-location)\jom\jom"

if ($LastExitCode -ne 0) { exit $LastExitCode }

echo building qtwebkit...
# Configure and build qtwebkit separately, as it needs ICU
cd qtwebkit
& ../qtbase/bin/qmake QT_CONFIG+=icu

if ($LastExitCode -ne 0) { exit $LastExitCode }

#nmake (jom is much faster)
& "$(get-location)\..\jom\jom"
cd ..

if ($LastExitCode -ne 0) { exit $LastExitCode }

python ./st_gen_and_upload_symbols.py --os $osname

if ($LastExitCode -ne 0) { exit $LastExitCode }

echo installing...
#nmake install
& "$(get-location)\jom\jom" install

if ($LastExitCode -ne 0) { exit $LastExitCode }

echo installing qtwebkit...
cd qtwebkit
#nmake install
& "$(get-location)\..\jom\jom" install
cd ..

if ($LastExitCode -ne 0) { exit $LastExitCode }

echo "copying icu..."
# Copy ICU dlls into the install dir
cp -Verbose $(ls "$icu_bindir/*.dll") "$version/bin"

ls "$version/lib/*icu*.dll"

if ($LastExitCode -ne 0) { exit $LastExitCode }

# Copy openssl dlls into the install dir
echo "copying openssl..."
cp -Verbose "$(get-location)/openssl/bin/*.dll" "$version/bin"

# Remove the pdb files from the build since the
# symbols have already been converted and uploaded to the server
get-childitem ./$version -include *.pdb -recurse | foreach ($_) {remove-item $_.fullname}

echo creating tarball...
cmake -E tar cvzf "qt-$version-$osname.tar.gz" "$version"

if ($LastExitCode -ne 0) { exit $LastExitCode }

# Delete the version folder, since the way teamcity cleans things having a folder that's
# also a revision is bad
rm -Force -Recurse ./$version
