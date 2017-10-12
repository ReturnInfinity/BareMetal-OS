#!/bin/bash

set -o errexit
set -u

mkdir -p src
mkdir -p bin

function clone {
  if [ ! -e src/$1 ]; then
    git clone https://github.com/ReturnInfinity/$1 src/$1
  else
    git --git-dir=src/$1/.git pull origin master
  fi
}

clone Alloy
clone BMFS
clone Pure64
clone BareMetal-kernel

make -C src/BMFS NO_FUSE=1 NO_UTIX_UTILS=1 PREFIX=$PWD install

bin/bmfs bin/bmfs.image initialize 128M

./build.sh
./format.sh
./install.sh
