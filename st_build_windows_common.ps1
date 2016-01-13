$osname = $args[0]

# Instantiate web client for downloads
$webclient = New-Object System.Net.WebClient

# Get the HEAD changeset which will be used to name the install folder
$version = $(git rev-parse HEAD)

echo "===== Downloading third-party dependencies..."
if ($osname -eq "win32") {
  cmake -D WIN32=1 -D X86=1 -D SW_DEV="$env:QT_BUILD_SWDEV" -P .\st_third_party.cmake
} else {
  cmake -D WIN32=1 -D SW_DEV="$env:QT_BUILD_SWDEV" -P .\st_third_party.cmake
}
if ($LastExitCode -ne 0) { exit $LastExitCode }
$third_party_dir = "$env:APPDATA\bacon\thirdparty"
$icu_dir = "$third_party_dir\icu4c\53.1-$osname"
echo "===== Downloaded ICU4C to `"$icu_dir`""
$libressl_dir = "$third_party_dir\libressl\2.2.1-$osname"
echo "===== Downloaded LibreSSL to `"$libressl_dir`""

echo "===== Configuring Qt..."
# We build with -no-icu and then enable it manually for QtWebKit. This means QtCore does not end up
# with an ICU dependency, so we can ship installers without ICU (which is huge)
.\configure.bat -prefix "$(get-location)\$version" -debug-and-release -force-debug-info -opensource -confirm-license -shared -platform win32-msvc2013 -D QT_NO_BEARERMANAGEMENT -I "$icu_dir\include" -I "$libressl_dir\include" -L "$icu_dir\lib" -L "$libressl_dir\lib" -openssl-linked -nomake examples -nomake tests -no-compile-examples -no-icu -mp -angle OPENSSL_LIBS="-llibssl-33 -llibcrypto-34 -llibtls-4"
if ($LastExitCode -ne 0) { exit $LastExitCode }

echo "===== Setting PATH..."
# Set up PATH to include qtbase\lib and $icu_dir\bin, which seems to be necessary for Qt 5.1
$env:PATH += ";$icu_dir\bin;$(get-location)\qtbase\lib"

echo "===== Building Qt..."
& .\jom\jom
if ($LastExitCode -ne 0) { exit $LastExitCode }

echo "===== Configuring QtWebKit..."
# Configure QtWebKit separately, as it needs ICU
cd qtwebkit
& ..\qtbase\bin\qmake QT_CONFIG+=icu
cd ..
if ($LastExitCode -ne 0) { exit $LastExitCode }

echo "===== Building qtwebkit..."
# Build QtWebKit separately, as it needs ICU
cd qtwebkit
& ..\jom\jom
cd ..
if ($LastExitCode -ne 0) { exit $LastExitCode }

echo "===== Generating and uploading symbols..."
python .\st_gen_and_upload_symbols.py --os $osname
if ($LastExitCode -ne 0) { exit $LastExitCode }

echo "===== Installing Qt..."
& .\jom\jom install
if ($LastExitCode -ne 0) { exit $LastExitCode }

echo "===== Installing QtWebKit..."
cd qtwebkit
& ..\jom\jom install
cd ..
if ($LastExitCode -ne 0) { exit $LastExitCode }

echo "===== Copying ICU..."
copy-item -verbose $(ls "$icu_dir\lib\*.dll") "$version\bin"
if ($LastExitCode -ne 0) { exit $LastExitCode }

echo "===== Copying LibreSSL..."
copy-item -verbose "$libressl_dir\lib\*.dll" "$version\bin"
if ($LastExitCode -ne 0) { exit $LastExitCode }

echo "===== Removing PDB files..."
# Remove the pdb files from the build since the
# symbols have already been converted and uploaded to the server
get-childitem .\$version -include *.pdb -recurse | foreach ($_) {remove-item $_.fullname}
if ($LastExitCode -ne 0) { exit $LastExitCode }

echo "===== Creating tarball..."
cmake -E tar cvzf "qt-$version-$osname.tar.gz" "$version"
if ($LastExitCode -ne 0) { exit $LastExitCode }

echo "===== Deleting version folder..."
# Delete the version folder, since the way teamcity cleans things having a folder that's
# also a revision is bad
remove-item -force -recurse .\$version
