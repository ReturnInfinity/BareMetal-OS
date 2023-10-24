#!/bin/sh

./clean.sh

mkdir src
mkdir -p sys/drive/EFI/BOOT

echo Pulling code from GitHub...
cd src
git clone https://github.com/ReturnInfinity/Pure64.git -q
git clone https://github.com/ReturnInfinity/BareMetal.git -q
git clone https://github.com/ReturnInfinity/BareMetal-Monitor.git -q
git clone https://github.com/ReturnInfinity/BMFS.git -q
git clone https://github.com/ReturnInfinity/BareMetal-Demo.git -q
cd ..

echo Downloading UEFI firmware...
cd sys
if which curl &> /dev/null; then
	curl -s -o OVMF.fd https://cdn.download.clearlinux.org/image/OVMF.fd
else
	wget https://cdn.download.clearlinux.org/image/OVMF.fd
fi
cd ..

echo Creating disk image...
cd sys
dd if=/dev/zero of=disk.img count=128 bs=1048576 > /dev/null 2>&1
dd if=/dev/zero of=null.bin count=8 bs=1 > /dev/null 2>&1
cd ..

cd src/BareMetal-Monitor
./setup.sh
cd ../..
cd src/BareMetal-Demo
./setup.sh
cd ../..

./build.sh

cd sys
./bmfs disk.img format
cd ..
./install.sh

echo Done!
