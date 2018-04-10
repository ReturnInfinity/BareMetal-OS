#!/bin/sh

git submodule init src/BareMetal-newlib
git submodule update src/BareMetal-newlib

cd src/BareMetal-newlib
./build-newlib.sh
