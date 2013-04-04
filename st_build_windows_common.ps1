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
$webclient.DownloadFile("http://repo.suitabletech.com/downloads/openssl-1.0.1e-$osname.zip", "$(get-location)/openssl.zip")

echo "unzipping openssl..."
& ./unzip.exe openssl.zip

$version = $(git rev-parse HEAD)
echo configuring ...
.\configure.bat -debug-and-release -force-debug-info -no-vcproj -opensource -confirm-license -shared -nomake docs -nomake examples -nomake demos -nomake tests -nomake translations -mp -icu -angle -openssl-linked OPENSSL_LIBS="-lssleay32 -llibeay32" -prefix "$(get-location)\$version" -I "$(get-location)\icu\include" -L "$icu_libdir" -I "$(get-location)\openssl\include" -L "$(get-location)\openssl\lib"

if ($LastExitCode -ne 0) { exit $LastExitCode }

# Setup PATH to include <qtbase>/lib and <icu>/bin, which seems to be necessary for Qt 5.1
$env:PATH += ";$icu_bindir;$(get-location)\qtbase\lib"

echo building...
nmake

if ($LastExitCode -ne 0) { exit $LastExitCode }

echo installing...
nmake install

if ($LastExitCode -ne 0) { exit $LastExitCode }

echo "copying icu..."
# Copy ICU dlls into the install dir
cp -Verbose $(ls "$icu_bindir/*.dll") "$version/bin"

ls "$version/lib/*icu*.dll"

if ($LastExitCode -ne 0) { exit $LastExitCode }

# Copy openssl dlls into the install dir
echo "copying openssl..."
cp -Verbose "$(get-location)/openssl/bin/*.dll" "$version/bin"

echo creating tarball...
cmake -E tar cvzf "qt-$version-$osname.tar.gz" "$version"

if ($LastExitCode -ne 0) { exit $LastExitCode }

# Delete the version folder, since the way teamcity cleans things having a folder that's
# also a revision is bad
rm -Force -Recurse ./$version