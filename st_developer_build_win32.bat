@echo off
setLocal enableExtensions

rem This is intended to be run from the Visual Studio Command Prompt for the desired Visual Studio version.

if not exist "%QT_BUILD_SWDEV%" (
  echo "Please set QT_BUILD_SWDEV to a valid sw-dev directory path; %QT_BUILD_SWDEV% does not exist"
  exit /b 1
)

set BUILD_DIRECTORY=%CD%
set SOURCE_DIRECTORY=%~dp0
if %SOURCE_DIRECTORY:~-1%==\ set SOURCE_DIRECTORY=%SOURCE_DIRECTORY:~0,-1%

cmake -D WIN32=1 -D X86=1 -D SW_DEV="%QT_BUILD_SWDEV%" -P "%SOURCE_DIRECTORY%\st_third_party.cmake"
set THIRD_PARTY_DIRECTORY=%APPDATA%\bacon\thirdparty
set ICU_DIRECTORY=%THIRD_PARTY_DIRECTORY%\icu4c\53.1-win32
set SSL_DIRECTORY=%THIRD_PARTY_DIRECTORY%\libressl\2.2.1-win32

xcopy /y /f /r "%ICU_DIRECTORY%\lib\*.dll" "%BUILD_DIRECTORY%\qtbase\bin\"
xcopy /y /f /r "%SSL_DIRECTORY%\lib\*.dll" "%BUILD_DIRECTORY%\qtbase\bin\"

call "%SOURCE_DIRECTORY%\configure" -debug-and-release -force-debug-info -developer-build -opensource -confirm-license -shared -platform win32-msvc2013 -D QT_NO_BEARERMANAGEMENT -I "%ICU_DIRECTORY%\include" -I "%SSL_DIRECTORY%\include" -L "%ICU_DIRECTORY%\lib" -L "%SSL_DIRECTORY%\lib" -openssl-linked -nomake examples -nomake tests -no-compile-examples -icu -mp -angle OPENSSL_LIBS="-llibssl-33 -llibcrypto-34 -llibtls-4"
set SOURCE_ROOT=%SOURCE_DIRECTORY%\qtwebkit\Source\WebCore
call "%SOURCE_DIRECTORY%\jom\jom"
