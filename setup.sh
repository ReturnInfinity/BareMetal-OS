#!/bin/sh

set -o errexit
set -u

mkdir -p src
mkdir -p bin

if [ ! -e src/Alloy ]; then
  git clone https://github.com/ReturnInfinity/Alloy.git src/Alloy
else
  git --git-dir=src/Alloy/.git pull origin master
fi

if [ ! -e src/BMFS ]; then
  git clone https://github.com/ReturnInfinity/BMFS.git src/BMFS
else
  git --git-dir=src/BMFS/.git pull origin master
fi

if [ ! -e src/Pure64 ]; then
  git clone https://github.com/ReturnInfinity/Pure64.git src/Pure64
else
  git --git-dir=src/Pure64/.git pull origin master
fi

if [ ! -e src/BareMetal-OS ]; then
  git clone https://github.com/ReturnInfinity/BareMetal-OS.git src/BareMetal-OS
else
  git --git-dir=src/BareMetal-OS/.git pull origin master
fi

make -C src/BMFS NO_FUSE=1 NO_UTIX_UTILS=1

cp --update src/BMFS/bmfs bin/bmfs

bin/bmfs bin/bmfs.image initialize 128M

./build.sh
./format.sh
./install.sh
