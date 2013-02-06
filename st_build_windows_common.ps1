$osname = $args[0]

echo configuring ...
.\configure.exe -debug-and-release -opensource -confirm-license -shared -webkit -mp -no-phonon

if ($LastExitCode -ne 0) { exit $LastExitCode }

echo building...
nmake

if ($LastExitCode -ne 0) { exit $LastExitCode }

echo cleaning ...
nmake clean

if ($LastExitCode -ne 0) { exit $LastExitCode }

rm lib/*.dll
rm -R -Force examples
rm -R -Force demos
rm -R -Force doc
rm -R -Force tests
ls . -R -include *.obj | rm -Force

if ($LastExitCode -ne 0) { exit $LastExitCode }

$version = $(git rev-parse HEAD)
$tmpdir = "$env:TEMP/$version"

echo $tmpdir

mkdir $tmpdir

echo "copying qt to $tmpdir ..."
cp -R -Force -Exclude .git * $tmpdir

if ($LastExitCode -ne 0) { exit $LastExitCode }

echo creating tarball...
push-location
cd "$tmpdir/.."
cmake -E tar cvzf "qt-$version-$osname.tar.gz" "$version"
pop-location
mv "$tmpdir/../qt-$version-$osname.tar.gz" .

if ($LastExitCode -ne 0) { exit $LastExitCode }