#!/bin/sh

cd src/BareMetal-Demo/bin
cp *.app ../../../sys/
cd ../../../sys/
./bmfs disk.img create hello.app 2
./bmfs disk.img write hello.app
./bmfs disk.img create sysinfo.app 2
./bmfs disk.img write sysinfo.app
