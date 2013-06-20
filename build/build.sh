#!/bin/sh

cd ../Pure64
./build.sh
mv bmfs_mbr.sys ../build/
mv pxestart.sys ../build/
mv pure64.sys ../build/
cd ..

cd BMFS
make
mv bmfs ../build/
cd ..

cd BareMetal-OS
./build.sh
mv kernel64.sys ../build/
