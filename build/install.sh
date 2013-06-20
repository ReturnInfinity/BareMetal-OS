#!/bin/sh

echo Writing Master Boot Record
dd if=bmfs_mbr.sys of=bmfs.image bs=512 conv=notrunc
echo Writing Pure64+Software
cat pure64.sys kernel64.sys > software.sys
dd if=software.sys of=bmfs.image bs=512 seek=16 conv=notrunc
