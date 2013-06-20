#!/bin/sh

git clone https://github.com/ReturnInfinity/BMFS.git
git clone https://github.com/ReturnInfinity/Pure64.git
git clone https://github.com/ReturnInfinity/BareMetal-OS.git
dd if=/dev/zero of=build/bmfs.image bs=1M count=128
cd build
./build.sh
./setup.sh
./install.sh
