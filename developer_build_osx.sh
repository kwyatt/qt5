#!/bin/bash

./configure -developer-build -release -opensource -confirm-license -shared -nomake examples  -no-c++11 -platform macx-clang
make -j8
