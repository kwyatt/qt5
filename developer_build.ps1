.\configure.bat -release -developer-build -opensource -confirm-license -shared -nomake examples -nomake tests -mp -angle -D QT_NO_BEARERMANAGEMENT -no-compile-examples -skip qtwebkit -skip qttools
#jom
nmake
