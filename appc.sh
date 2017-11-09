#!/bin/sh

set -e
set -u

export OUTPUT_DIR="$PWD/output"

CC=gcc
CFLAGS=
CFLAGS="${CFLAGS} -Wall -Wextra -Werror -Wfatal-errors -std=gnu99"
CFLAGS="${CFLAGS} -m64 -nostdlib -nostartfiles -nodefaultlibs -fomit-frame-pointer -mno-red-zone -fPIC"
CFLAGS="${CFLAGS} -I$OUTPUT_DIR/include"
CFLAGS="${CFLAGS} -Wl,-T src/Coreutils/coreutil.ld"
LIBS="$OUTPUT_DIR/lib/libc.a $OUTPUT_DIR/lib/libbmfs.a"

$CC $CFLAGS src/Coreutils/$1.c -o "$OUTPUT_DIR/apps/$1.app" $LIBS
cd "$OUTPUT_DIR"
bin/bmfs baremetal-os.img delete $1.app
bin/bmfs baremetal-os.img create $1.app 2
bin/bmfs baremetal-os.img write $1.app "apps/$1.app"
cd ..
