#!/bin/sh

cd src/Pure64
./build.sh
mv *.sys ../../bin/
mv *.lst ../../lst/
cd ..

cd BareMetal-OS/os
nasm kernel64.asm -o ../../../bin/kernel64.sys -l ../../../lst/kernel64.lst
