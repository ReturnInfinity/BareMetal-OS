#!/bin/sh

./clean.sh

mkdir src
mkdir sys
cd src

echo Pulling code from GitHub...
git clone https://github.com/ReturnInfinity/Pure64.git -q
git clone https://github.com/ReturnInfinity/BareMetal.git -q
git clone https://github.com/ReturnInfinity/BareMetal-Monitor.git -q
git clone https://github.com/ReturnInfinity/BMFS.git -q

cd ..

cd src/BareMetal-Monitor
./setup.sh
cd ../..

echo Creating disk image...
cd sys
dd if=/dev/zero of=disk.img count=128 bs=1048576
dd if=/dev/zero of=null.bin count=8 bs=1
cd ..

./build.sh
cd sys
./bmfs disk.img format
cd ..
./install.sh monitor.bin
