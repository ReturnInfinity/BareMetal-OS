#!/bin/sh

set -u
set -e

nasm -Isrc/Coreutils/ src/Coreutils/$1.asm -o bin/$1.app
cd bin
./bmfs bmfs.image delete $1.app
./bmfs bmfs.image create $1.app 2
./bmfs bmfs.image write $1.app
cd ..
