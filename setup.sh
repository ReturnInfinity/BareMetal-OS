#!/bin/sh

set -o errexit
set -u

mkdir -p src
mkdir -p dst

if [ ! -e src/BMFS ]; then
  git clone https://github.com/ReturnInfinity/BMFS.git
else
  git --git-dir=src/BMFS/.git pull origin master
fi

if [ ! -e src/Pure64 ]; then
  git clone https://github.com/ReturnInfinity/Pure64.git
else
  git --git-dir=src/Pure64/.git pull origin master
fi

if [ ! -e src/BareMetal-OS ]; then
  git clone https://github.com/ReturnInfinity/BareMetal-OS.git
else
  git --git-dir=src/BareMetal-OS/.git pull origin master
fi

make -C src/BMFS NO_FUSE=1

cp --update src/BMFS/bmfs bin/bmfs

bin/bmfs bin/bmfs.image initialize 128M

./build.sh
./format.sh
./install.sh
