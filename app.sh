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
CFLAGS+=" -Wl,-T src/Examples/coreutil.ld"
LIBS="$OUTPUT_DIR/lib/libc.a $OUTPUT_DIR/lib/libbmfs.a"


# if no filename is passed, list files
if [[ $# -eq 0 ]]; then
    echo "Enter a filename to compile"
    echo
    echo "Available options:"
    echo "$(ls "$PWD/src/Examples" | grep '\.asm')"
    echo "$(ls "$PWD/src/Examples" | grep '\.c')"
    exit 0
fi


# get file extention
ext=${1##*.}
fname=${1%.*}


# create a apps directory if not present
mkdir -p "$OUTPUT_DIR/apps"

# compile 'em!
if [[ "$ext" == "asm" ]]; then
    nasm -Isrc/Examples/ src/Examples/$fname.asm -o "$OUTPUT_DIR/apps/$fname.app"
elif [[ "$ext" == "c" ]]; then
    $CC $CFLAGS src/Examples/$fname.c -o "$OUTPUT_DIR/apps/$fname.app" $LIBS
elif [[ "$ext" == "" ]]; then
	echo "No file extension found."
	exit 1
else
	echo "Unknown file extension '$ext'"
	exit 1
fi

# put in filesystem
cd "$OUTPUT_DIR"
bin/bmfs --disk baremetal-os.img --offset 32KiB rm -f "/Applications/$fname.app"
bin/bmfs --disk baremetal-os.img --offset 32KiB cp "$OUTPUT_DIR/apps/$fname.app" "/Applications/$fname.app"
cd ..
