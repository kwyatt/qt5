$BUILD_DIRECTORY = $(get-location)
echo "Build directory: $BUILD_DIRECTORY"

$SOURCE_DIRECTORY = $(split-path $script:MyInvocation.MyCommand.Path)
echo "Source directory: $SOURCE_DIRECTORY"

$osname = $args[0]
echo "OS: $osname"

# Get the HEAD changeset which will be used to name the install folder
(set-location $SOURCE_DIRECTORY)
$version = $(& "$env:TEAMCITY_GIT_PATH" rev-parse HEAD)
(set-location $BUILD_DIRECTORY)
if (!($version)) {
  echo "Error: could not get the revision."
  exit 1
}
echo "Revision: $version"

# Get sw-dev directory.
$sw_dev = "$BUILD_DIRECTORY\sw-dev"
if (-not (test-path "$sw_dev" -pathtype container)) {
  $sw_dev = "$env:QT_BUILD_SWDEV"
  if (-not "$sw_dev") {
    echo "Please set QT_BUILD_SWDEV to a valid sw-dev directory path."
    exit 1;
  }
  if (-not (test-path "$sw_dev" -pathtype container)) {
    echo "Please set QT_BUILD_SWDEV to a valid sw-dev directory path; `"$sw_dev`" does not exist."
    exit 1;
  }
}
echo "SW-DEV: $sw_dev"

if ($osname -eq "win32") {
  cmake -D WIN32=1 -D X86=1 -D SW_DEV="$sw_dev" -P "$SOURCE_DIRECTORY\st_third_party.cmake"
} else {
  cmake -D WIN32=1 -D SW_DEV="$sw_dev" -P "$SOURCE_DIRECTORY\st_third_party.cmake"
}
if ($LastExitCode -ne 0) { exit $LastExitCode }
$third_party_dir = "$env:APPDATA\bacon\thirdparty"
$libressl_dir = "$third_party_dir\libressl\2.2.1-$osname"
echo "Downloaded LibreSSL to `"$libressl_dir`"."

& "$SOURCE_DIRECTORY\configure.bat" -prefix "$BUILD_DIRECTORY\$version" -debug-and-release -force-debug-info -opensource -confirm-license -shared -platform win32-msvc2013 -D QT_NO_BEARERMANAGEMENT -I "$libressl_dir\include" -L "$libressl_dir\lib" -openssl-linked -nomake examples -nomake tests -skip qtwebkit -no-compile-examples -no-icu -mp -opengl dynamic OPENSSL_LIBS="-llibssl-33 -llibcrypto-34 -llibtls-4"
if ($LastExitCode -ne 0) { exit $LastExitCode }
echo "Configuration complete."

jom
if ($LastExitCode -ne 0) { exit $LastExitCode }
echo "Make complete."

python "$SOURCE_DIRECTORY\st_gen_and_upload_symbols.py" --os $osname --swdev "$sw_dev"
if ($LastExitCode -ne 0) { exit $LastExitCode }
echo "Symbol upload complete."

jom install
if ($LastExitCode -ne 0) { exit $LastExitCode }
echo "Installation to staging directory complete."

copy-item -verbose "$libressl_dir\lib\*.dll" ".\$version\bin"
if ($LastExitCode -ne 0) { exit $LastExitCode }
echo "LibreSSL copy to staging directory complete."

# Remove the pdb files from the build since the
# symbols have already been converted and uploaded to the server
get-childitem .\$version -include *.pdb -recurse | foreach ($_) {remove-item $_.fullname}
if ($LastExitCode -ne 0) { exit $LastExitCode }
echo "PDB file removal from staging directory complete."

cmake -E tar cvzf "qt-$version-$osname.tar.gz" ".\$version"
if ($LastExitCode -ne 0) { exit $LastExitCode }
echo "Tarball generation complete."

# Delete the version folder, since the way teamcity cleans things having a folder that's
# also a revision is bad
remove-item -force -recurse .\$version
echo "Staging directory deletion complete."
