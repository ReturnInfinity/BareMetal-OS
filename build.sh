#!/bin/sh

export topdir=$PWD

cd src

cd Alloy
./build.sh
mv alloy.bin ../../bin
cd ..

cd Pure64
./build.sh
mv *.sys ../../bin/
cd ..

cd BareMetal-kernel
./build_x86-64.sh
mv *.sys ../../bin
mv *.txt ../../bin
