#!/bin/bash

# set options and output directory
set -e
export OUTPUT_DIR="$PWD/output"

# c compiler options/flags
CC=gcc
CFLAGS="${CFLAGS}  -Wall -Wextra -Werror -Wfatal-errors -std=gnu99"
CFLAGS="${CFLAGS} -m64 -nostdlib -nostartfiles -nodefaultlibs -fomit-frame-pointer -mno-red-zone -mcmodel=large"
CFLAGS="${CFLAGS} -I$OUTPUT_DIR/include"
CFLAGS="${CFLAGS} -g"

DC=ldc2
DFLAGS="${DFLAGS} -betterC -m64 -nodefaultlib --disable-red-zone -output-o -code-model=large"
DFLAGS="${DFLAGS} -I$OUTPUT_DIR/include"
DFLAGS="${DFLAGS} -g"

LD=ld
LDFLAGS="${LDFLAGS} -T src/Examples/example.ld"
LDFLAGS="${LDFLAGS} -z max-page-size=0x1000"

OBJCOPY=objcopy

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
    $CC $CFLAGS -c src/Examples/libBareMetal.c -o src/Examples/libBareMetal.o
    $CC $CFLAGS -c src/Examples/$fname.c -o src/Examples/$fname.o
    $LD $LDFLAGS src/Examples/libBareMetal.o src/Examples/$fname.o -o "$OUTPUT_DIR/apps/$fname.app"
elif [[ "$ext" == "d" ]]; then
    $CC $CFLAGS -c src/Examples/libBareMetal.c -o src/Examples/libBareMetal.o
    $DC $DFLAGS -c src/Examples/$fname.d -of=src/Examples/$fname.o
    $LD $LDFLAGS src/Examples/libBareMetal.o src/Examples/$fname.o -o "$OUTPUT_DIR/apps/$fname.app"
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
