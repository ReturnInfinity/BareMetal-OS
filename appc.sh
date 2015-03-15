#!/bin/sh
cd src/BareMetal-OS/programs/
gcc -I newlib-2.0.0/newlib/libc/include/ -c $1.c -o $1.o -DBAREMETAL
ld -T app.ld -o $1.app crt0.o $1.o libc.a libBareMetal.o
mv $1.app ../../../bin/
if [ $? -eq 0 ]; then
cd ../../../bin
./bmfs bmfs.image create $1.app 2
./bmfs bmfs.image write $1.app
cd ..
else
echo "Error"
fi
