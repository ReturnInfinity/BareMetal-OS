#!/bin/sh

if [ ! -d "$src" ]; then
  mkdir src
fi
if [ ! -d "$bin" ]; then
  mkdir bin
fi

cd src
git clone https://github.com/ReturnInfinity/BMFS.git
git clone https://github.com/ReturnInfinity/Pure64.git
git clone https://github.com/ReturnInfinity/BareMetal-OS.git
cd ..

cd src/BMFS
make
mv bmfs ../../bin/
cd ../../bin
./bmfs bmfs.image initialize 128M
cd ..

./build.sh
./format.sh
./install.sh
