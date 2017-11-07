#!/bin/sh

set -e

cd bin
echo Writing Pure64+Software
cat pure64.sys kernel.sys alloy.bin > software.sys
dd if=software.sys of=bmfs.image bs=512 seek=16 conv=notrunc 2>/dev/null
