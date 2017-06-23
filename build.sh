#!/bin/sh

cd src/Pure64
./build.sh
mv *.sys ../../bin/
cd ..

cd BareMetal-kernel
./build_x86-64.sh
mv *.sys ../../bin
mv *.txt ../../bin
