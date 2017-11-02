#!/bin/bash

set -e
set -u

export BMFS_INCLUDE_DIR=$PWD/src/BMFS/include
export BMFS_LIBRARY=$PWD/src/BMFS/src/libbmfs.a

export BAREMETAL_LIBC_INCLUDE_DIR=$PWD/src/ironlib/include
export BAREMETAL_LIBC_LIBRARY=$PWD/bin/libbaremetal.a

cd src

cd ironlib
./build.sh
mv libbaremetal.a ../../bin
cd ..

cd Alloy
./build.sh
mv alloy.bin ../../bin
cd ..

cd Pure64
./build.sh
mv *.sys ../../bin/
cd ..

cd kernel
./build_x86-64.sh
mv *.sys ../../bin
mv *.txt ../../bin
cd ..
