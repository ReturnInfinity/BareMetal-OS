#!/bin/sh

set -e

export OUTPUT_DIR="$PWD/sys"

cd "$OUTPUT_DIR"
echo Building OS image...

if [ "$#" -ne 1 ]; then
    cat pure64.sys kernel.sys monitor.bin > software.sys
else
    cat pure64.sys kernel.sys $1 > software.sys
fi

dd if=mbr.sys of=disk.img conv=notrunc > /dev/null 2>&1
dd if=software.sys of=disk.img bs=4096 seek=2 conv=notrunc > /dev/null 2>&1
cd ..
