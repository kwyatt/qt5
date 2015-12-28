#!/bin/bash

source set_swdev.sh

OPENSSL_LIBS=" " ./configure -developer-build -debug-and-release -opensource -confirm-license -xplatform macx-ios-clang -nomake tests -nomake examples -skip qttranslations -skip qtwebkit -no-warnings-are-errors -no-feature-bearermanagement -openssl-linked -I$SW_DEV/stacks/texas_videoconf/third_party/third_party/openssl/openssl/include

make -j8
