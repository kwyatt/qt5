$osname = $args[0]

# Grab ICU, which is required for building webkit
echo "downloading ICU..."
$webclient = New-Object System.Net.WebClient
$webclient.DownloadFile("http://repo.suitabletech.com/downloads/icu4c-50_1_2-$osname-msvc10.zip", "$(get-location)/icu.zip")

function unzip($filename) 
{ 
  if (!(test-path $filename)) { throw "$filename does not exist" } 
  $shell = new-object -com shell.application 
  $shell.namespace($pwd.path).copyhere($shell.namespace((join-path $pwd $filename)).items(), 0x14) 
}

# Unzipping icu
echo "unzipping ICU..."
unzip("icu.zip")

$icu_libdir = "$(get-location)\icu\lib"
if ($osname -eq "win64")
{
  $icu_libdir = "$(get-location)\icu\lib64"
}

$version = $(git rev-parse HEAD)
echo configuring ...
.\configure.bat -debug-and-release -force-debug-info -opensource -confirm-license -shared -nomake tools -nomake docs -nomake examples -nomake demos -nomake tests -mp -icu -prefix "$(get-location)\$version" -I "$(get-location)\icu\include" -L "$(get-location)\icu\lib" -L "$icu_libdir"

if ($LastExitCode -ne 0) { exit $LastExitCode }

echo building...
nmake

if ($LastExitCode -ne 0) { exit $LastExitCode }

echo installing...
nmake install

if ($LastExitCode -ne 0) { exit $LastExitCode }

echo creating tarball...
cmake -E tar cvzf "qt-$version-$osname.tar.gz" "$version"

if ($LastExitCode -ne 0) { exit $LastExitCode }

# Delete the version folder, since the way teamcity cleans things having a folder that's
# also a revision is bad
rm -Force -Recurse ./$version