#!/bin/sh

if [ ! -d "$src" ]; then
  mkdir src
fi
cd src
git clone https://github.com/ReturnInfinity/BMFS.git
git clone https://github.com/ReturnInfinity/Pure64.git
git clone https://github.com/ReturnInfinity/BareMetal-OS.git
cd ..

if [ ! -d "$build" ]; then
  mkdir build
fi
dd if=/dev/zero of=build/bmfs.image bs=1M count=128

./build.sh
./format.sh
./install.sh
