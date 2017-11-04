#!/bin/bash

set -e
set -u

export BMFS_INCLUDE_DIR=$PWD/include
export BMFS_LIBRARY=$PWD/lib/libbmfs.a

export BAREMETAL_LIBC_INCLUDE_DIR=$PWD/include
export BAREMETAL_LIBC_LIBRARY=$PWD/lib/libc.a

export PREFIX=$PWD

cd src

cd ironlib
./build.sh
./install.sh
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
