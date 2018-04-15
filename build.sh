#!/bin/bash

set -e
set -u

export OUTPUT_DIR="$PWD/output"

export ALLOY_WITH_BAREMETAL=1

export BMFS_INCLUDE_DIR="$OUTPUT_DIR/include"
export BMFS_LIBRARY="$OUTPUT_DIR/lib/libbmfs.a"

export BAREMETAL_LIBC_INCLUDE_DIR="$OUTPUT_DIR/include"
export BAREMETAL_LIBC_LIBRARY="$OUTPUT_DIR/lib/libc.a"

export PREFIX="$OUTPUT_DIR"

cd src

cd BMFS
./build.sh
./install.sh
cd ..

cd ironlib
./build.sh
./install.sh
cd ..

cd Alloy
./build.sh
mv src/loader.bin "$OUTPUT_DIR/system"
mv src/alloy "$OUTPUT_DIR/system"
mv src/alloy.bin "$OUTPUT_DIR/system"
cd ..

cd Pure64
./build.sh
mv *.sys "$OUTPUT_DIR/system"
cd ..

cd kernel
./build_x86-64.sh
mv src/x86-64/kernel.elf "$OUTPUT_DIR/system"
mv src/x86-64/kernel.bin "$OUTPUT_DIR/system"
cd ..
