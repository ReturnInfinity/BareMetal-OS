#!/bin/bash

set -o errexit
set -u

mkdir -p bin

git submodule update --init

make -C src/BMFS NO_FUSE=1 NO_UTIX_UTILS=1 PREFIX=$PWD install

bin/bmfs bin/bmfs.image initialize 128M

./build.sh
./format.sh
./install.sh
