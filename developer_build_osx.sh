#!/bin/bash

# See NCA-6261 and NCA-5990 for -no-harfbuzz rationale.
# FIXME: Revisit when updating Qt to 5.4.
./configure -developer-build -debug-and-release -opensource -confirm-license -shared -nomake examples  -no-c++11 -platform macx-clang -skip qtwebkit -no-feature-bearermanagement -no-compile-examples -no-harfbuzz
make -j8
