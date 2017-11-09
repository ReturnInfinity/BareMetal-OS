#!/bin/sh

set -e

cd bin
echo Formatting Disk Image
./bmfs bmfs.image initialize 128M
./bmfs bmfs.image format /force
./bmfs bmfs.image mkdir programs
echo Writing Master Boot Record
dd if=bmfs_mbr.sys of=bmfs.image bs=512 conv=notrunc 2>/dev/null
