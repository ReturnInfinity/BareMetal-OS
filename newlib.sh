#!/bin/sh

if [ ! -d "$newlib" ]; then
  mkdir newlib
fi
cd newlib
wget ftp://sourceware.org/pub/newlib/newlib-2.1.0.tar.gz
tar xf newlib-2.1.0.tar.gz
mkdir build
cd ..

