#!/bin/sh
# expecting source on programs/
# libc source on src/BareMetal-libc/src/
# libc includes on src/BareMetal-libc/include/

CFLAGS="-c -m64 -nostdlib -nostartfiles -nodefaultlibs -fomit-frame-pointer -mno-red-zone -I../src/BareMetal-libc/include/"

cd programs/
# main source file
gcc $CFLAGS -o $1.o $1.c
# libraries sources
gcc $CFLAGS -o baremetal.o ../src/BareMetal-libc/src/baremetal.c
gcc $CFALGS -o string.o ../src/BareMetal-libc/src/string.c
# 'generic' app.ld link
# linking with string.o, which may not always be needed
ld -T app.ld -o ../bin/$1.app $1.o baremetal.o string.o

if [ $? -eq 0 ]; then
cd ../bin
./bmfs bmfs.image create $1.app 2
./bmfs bmfs.image write $1.app
cd ..
else
echo "Error"
fi
