@echo off
setLocal enableExtensions

rem This is intended to be run from the Visual Studio Command Prompt for the desired Visual Studio version.

if not exist "%QT_BUILD_SWDEV%" (
  echo "Please set QT_BUILD_SWDEV to a valid sw-dev directory path; %QT_BUILD_SWDEV% does not exist"
  exit /b 1
)

set BUILD_DIRECTORY=%CD%
echo "Build directory: %BUILD_DIRECTORY%"

set SOURCE_DIRECTORY=%~dp0
if %SOURCE_DIRECTORY:~-1%==\ set SOURCE_DIRECTORY=%SOURCE_DIRECTORY:~0,-1%
echo "Source directory: %SOURCE_DIRECTORY%"

cmake -D WIN32=1 -D X86=1 -D SW_DEV="%QT_BUILD_SWDEV%" -P "%SOURCE_DIRECTORY%\st_third_party.cmake"
set THIRD_PARTY_DIRECTORY=%APPDATA%\bacon\thirdparty
set SSL_DIRECTORY=%THIRD_PARTY_DIRECTORY%\libressl\2.2.1-win32
echo "SSL directory: %SSL_DIRECTORY%"

xcopy /y /f /r "%SSL_DIRECTORY%\lib\*.dll" "%BUILD_DIRECTORY%\qtbase\bin\"
echo "Copy of SSL libraries into bin complete."

call "%SOURCE_DIRECTORY%\configure" -debug-and-release -force-debug-info -developer-build -opensource -confirm-license -shared -platform win32-msvc2013 -D QT_NO_BEARERMANAGEMENT -I "%SSL_DIRECTORY%\include" -L "%SSL_DIRECTORY%\lib" -openssl-linked -nomake examples -nomake tests -skip qtwebkit -no-compile-examples -no-icu -mp -angle OPENSSL_LIBS="-llibssl-33 -llibcrypto-34 -llibtls-4"
echo "Configuration complete."

call "%SOURCE_DIRECTORY%\jom\jom"
echo "Make complete."
