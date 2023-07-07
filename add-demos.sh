#!/bin/sh

cd src/BareMetal-Demo/bin
cp *.app ../../../sys/
cd ../../../sys/
./bmfs disk.img create hello.app 2
./bmfs disk.img write hello.app
./bmfs disk.img create ethtest.app 2
./bmfs disk.img write ethtest.app
./bmfs disk.img create sysinfo.app 2
./bmfs disk.img write sysinfo.app
./bmfs disk.img create euler1.app 2
./bmfs disk.img write euler1.app
./bmfs disk.img create helloc.app 2
./bmfs disk.img write helloc.app
./bmfs disk.img create gavare.app 2
./bmfs disk.img write gavare.app
