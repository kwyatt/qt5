$osname = $args[0]

# Grab ICU, which is required for building webkit
echo "downloading ICU..."
$webclient = New-Object System.Net.WebClient
$webclient.DownloadFile("http://repo.suitabletech.com/downloads/icu_53_1_msvc_2013_${osname}_devel.zip", "$(get-location)/icu.zip")

# Unzip icu
echo "unzipping ICU..."
& ./unzip.exe "icu.zip"

$icu_libdir = "$(get-location)\icu53_1\lib"
$icu_bindir = "$(get-location)\icu53_1\bin"

# Grab LibreSSL, an OpenSSL replacement which is required for https support
# We can't use OpenSSL because of http://rt.openssl.org/Ticket/Display.html?id=3828&user=guest&pass=guest
echo "downloading libressl..."
$webclient.DownloadFile("http://repo.suitabletech.com/downloads/libressl-2.2.1-windows.zip", "$(get-location)/libressl.zip")

echo "unzipping libressl..."
& ./unzip.exe libressl.zip

$version = $(git rev-parse HEAD)
echo configuring ...
# We build with -no-icu and then enable it manually for QtWebKit. This means QtCore does not end up
# with an ICU dependency, so we can ship installers without ICU (which is huge)

if ($osname -eq "win32") { $libressl_lib = "$(get-location)\libressl\x86" }
else { $libressl_lib = "$(get-location)\libressl\x64" }

.\configure.bat -debug-and-release -force-debug-info -opensource -confirm-license -shared -nomake examples -nomake tests -mp -no-icu -angle -openssl-linked OPENSSL_LIBS="-llibssl-33 -llibcrypto-34 -llibtls-4" -prefix "$(get-location)\$version" -I "$(get-location)\icu\include" -L "$icu_libdir" -I "$(get-location)\libressl\include" -L $libressl_lib -D QT_NO_BEARERMANAGEMENT -platform win32-msvc2013

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
cp -Verbose $(ls "$icu_libdir/*.dll") "$version/bin"

ls "$version/lib/*icu*.dll"

if ($LastExitCode -ne 0) { exit $LastExitCode }

# Copy libressl dlls into the install dir
echo "copying libressl..."
cp -Verbose "$libressl_lib/*.dll" "$version/bin"

# Remove the pdb files from the build since the
# symbols have already been converted and uploaded to the server
get-childitem ./$version -include *.pdb -recurse | foreach ($_) {remove-item $_.fullname}

echo creating tarball...
cmake -E tar cvzf "qt-$version-$osname.tar.gz" "$version"

if ($LastExitCode -ne 0) { exit $LastExitCode }

# Delete the version folder, since the way teamcity cleans things having a folder that's
# also a revision is bad
rm -Force -Recurse ./$version
