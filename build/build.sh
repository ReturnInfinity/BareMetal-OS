#!/bin/sh

cd ../Pure64
./build.sh
mv *.sys ../build/
cd ..

cd BMFS
make
mv bmfs ../build/
cd ..

cd BareMetal-OS/os
nasm kernel64.asm -o ../../build/kernel64.sys

