#!/bin/sh

if [ ! -d "$newlib" ]; then
  mkdir newlib
fi
cd newlib
wget ftp://sourceware.org/pub/newlib/newlib-2.1.0.tar.gz
tar xf newlib-2.1.0.tar.gz
mkdir build

cd ../src/BareMetal-OS/newlib/patches
cp config.sub.patch ../../../../newlib/newlib-2.1.0/
cp configure.host.patch ../../../../newlib/newlib-2.1.0/newlib/
cp configure.in.patch ../../../../newlib/newlib-2.1.0/newlib/libc/sys/
cd ../../../../newlib

mkdir newlib-2.1.0/newlib/libc/sys/baremetal
cp ../src/BareMetal-OS/newlib/baremetal/* newlib-2.1.0/newlib/libc/sys/baremetal/

cd newlib-2.1.0/newlib/libc/sys
autoconf
cd baremetal
autoreconf
cd ../../../../../build

../newlib-2.1.0/configure --target=x86_64-pc-baremetal --disable-multilib

sed -i 's/TARGET=x86_64-pc-baremetal-/TARGET=/g' Makefile
sed -i 's/WRAPPER) x86_64-pc-baremetal-/WRAPPER) /g' Makefile

make

cd x86_64-pc-baremetal/newlib/
cp libc.a ../../..
cp libm.a ../../..
cp crt0.o ../../..
cd ../../..

