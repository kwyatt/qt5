#!/bin/bash

./configure -developer-build -debug-and-release -opensource -confirm-license -shared -nomake examples -platform macx-clang -skip qtwebkit -no-feature-bearermanagement -no-compile-examples
make -j8
