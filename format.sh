#!/bin/sh
cd build
echo Formatting Disk Image
./bmfs bmfs.image format
echo Writing Master Boot Record
dd if=bmfs_mbr.sys of=bmfs.image bs=512 conv=notrunc
