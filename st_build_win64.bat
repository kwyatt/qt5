@echo off

call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x64
powershell .\st_build_windows_common.ps1 win64
