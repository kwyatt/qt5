#!/bin/bash

./configure -developer-build -debug-and-release -opensource -confirm-license -xplatform macx-ios-clang -nomake tests -nomake examples -skip qttranslations -skip qtwebkit -no-warnings-are-errors -no-feature-bearermanagement

make -j8
