#!/bin/sh

set -e

export OUTPUT_DIR="$PWD/sys"

cd "$OUTPUT_DIR"
echo Building OS image...

if [ "$1" != "" ]; then
	cat pure64.sys kernel.sys $1 > software.sys
else
	cat pure64.sys kernel.sys null.bin > software.sys
fi

dd if=mbr.sys of=disk.img conv=notrunc > /dev/null 2>&1
dd if=software.sys of=disk.img bs=512 seek=16 conv=notrunc > /dev/null 2>&1
cd ..
