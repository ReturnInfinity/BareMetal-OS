#!/bin/bash

# set options and output directory
set -u
set -e
export OUTPUT_DIR="$PWD/output"

# c compiler options/flags
CC=gcc
CFLAGS=""
CFLAGS+=" -Wall -Wextra -Werror -Wfatal-errors -std=gnu99"
CFLAGS+=" -m64 -nostdlib -nostartfiles -nodefaultlibs -fomit-frame-pointer -mno-red-zone -fpie"
CFLAGS+=" -I$OUTPUT_DIR/include"
CFLAGS+=" -Wl,-T src/Coreutils/coreutil.ld"
LIBS="$OUTPUT_DIR/lib/libc.a $OUTPUT_DIR/lib/libbmfs.a"


# if no filename is passed, list files
if [[ $# -eq 0 ]]; then
    echo "Enter a filename to compile"
    echo
    echo "Available options:"
    echo "$(ls "$PWD/src/Coreutils" | grep '\.asm')"
    echo "$(ls "$PWD/src/Coreutils" | grep '\.c')"
    exit 0
fi


# get file extention
ext=${1##*.}
fname=${1%.*}


# create a apps directory if not present
mkdir -p "$OUTPUT_DIR/apps"

# compile 'em!
if [[ "$ext" == "asm" ]]; then
    nasm -Isrc/Coreutils/ src/Coreutils/$fname.asm -o "$OUTPUT_DIR/apps/$fname.app"
elif [[ "$ext" == "c" ]]; then
    $CC $CFLAGS src/Coreutils/$fname.c -o "$OUTPUT_DIR/apps/$fname.app" $LIBS
fi

# put in filesystem
cd "$OUTPUT_DIR"
bin/bmfs baremetal-os.img delete $fname.app
bin/bmfs baremetal-os.img create $fname.app 2
bin/bmfs baremetal-os.img write $fname.app "$OUTPUT_DIR/apps/$fname.app"
cd ..
