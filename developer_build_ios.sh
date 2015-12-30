#!/bin/bash

source set_swdev.sh

# TODO: Remove OpenSSL in favor of securetransport starting with Qt 5.5?
#./configure -prefix $install_dir -debug-and-release -opensource -confirm-license -xplatform macx-ios-clang -nomake tests -nomake examples -skip qttranslations -skip qtwebkit -no-warnings-are-errors -no-feature-bearermanagement -no-openssl -securetransport
OPENSSL_LIBS=" " ./configure -developer-build -debug-and-release -opensource -confirm-license -xplatform macx-ios-clang -nomake tests -nomake examples -skip qttranslations -skip qtwebkit -no-warnings-are-errors -no-feature-bearermanagement -openssl-linked -I$SW_DEV/stacks/texas_videoconf/third_party/third_party/openssl/openssl/include

make -j8
