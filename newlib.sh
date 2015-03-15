#!/bin/sh

if [ ! -d "$newlib" ]; then
  mkdir newlib
fi
cd newlib

echo Downloading Newlib

wget ftp://sourceware.org/pub/newlib/newlib-2.2.0.tar.gz
tar xf newlib-2.2.0.tar.gz
mkdir build

echo Configuring Newlib

cd ../src/BareMetal-OS/newlib/patches
cp config.sub.patch ../../../../newlib/newlib-2.2.0/
cp configure.host.patch ../../../../newlib/newlib-2.2.0/newlib/
cp configure.in.patch ../../../../newlib/newlib-2.2.0/newlib/libc/sys/
cd ../../../../newlib
cd newlib-2.2.0
patch < config.sub.patch
cd newlib
patch < configure.host.patch
cd libc/sys
patch < configure.in.patch
cd ../../../..

mkdir newlib-2.2.0/newlib/libc/sys/baremetal
cp ../src/BareMetal-OS/newlib/baremetal/* newlib-2.2.0/newlib/libc/sys/baremetal/

cd newlib-2.2.0/newlib/libc/sys
autoconf
cd baremetal
autoreconf
cd ../../../../../build

../newlib-2.2.0/configure --target=x86_64-pc-baremetal --disable-multilib

sed -i 's/TARGET=x86_64-pc-baremetal-/TARGET=/g' Makefile
sed -i 's/WRAPPER) x86_64-pc-baremetal-/WRAPPER) /g' Makefile

echo Building Newlib

make

echo Build complete!

echo Copying libraries into BareMetal programs directory...
cd x86_64-pc-baremetal/newlib/
cp libc.a ../../../../src/BareMetal-OS/programs/
cp libm.a ../../../../src/BareMetal-OS/programs/
cp lib0.o ../../../../src/BareMetal-OS/programs/
cd ../../../newlib-2.2.0/newlib
cp libc ../../../src/BareMetal-OS/programs/

echo Building test program (test.app)
cd ../../../
appc.sh test
echo Complete!
