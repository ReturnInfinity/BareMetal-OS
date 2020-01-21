#!/bin/sh

./clean.sh

mkdir src
mkdir sys
cd src

git clone https://github.com/ReturnInfinity/Pure64.git
git clone https://github.com/ReturnInfinity/BareMetal.git

cd ..
cd sys
dd if=/dev/zero of=disk.img count=128 bs=1048576
dd if=/dev/zero of=null.bin count=8 bs=1
cd ..

./build.sh
./install.sh
