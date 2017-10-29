#!/bin/sh

set -e
set -u


CC=gcc
CFLAGS=
CFLAGS="${CFLAGS} -Wall -Wextra -Werror -Wfatal-errors"
CFLAGS="${CFLAGS} -m64 -nostdlib -nostartfiles -nodefaultlibs -fomit-frame-pointer -mno-red-zone"
CFLAGS="${CFLAGS} -Wl,-T src/Coreutils/coreutil.ld"
LIBS="bin/libbaremetal.a"

$CC $CFLAGS src/Coreutils/$1.c -o bin/$1.app $LIBS
cd bin
./bmfs bmfs.image delete $1.app
./bmfs bmfs.image create $1.app 2
./bmfs bmfs.image write $1.app
cd ..
