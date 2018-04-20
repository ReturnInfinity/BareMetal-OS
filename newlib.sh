#!/bin/sh

git submodule init src/newlib
git submodule update src/newlib

cd src/newlib
./build-newlib.sh
