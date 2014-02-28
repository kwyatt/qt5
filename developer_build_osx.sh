#!/bin/bash

./configure -developer-build -debug-and-release -opensource -confirm-license -shared -nomake examples  -no-c++11 -platform macx-clang
make -j8
