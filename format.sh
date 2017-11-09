#!/bin/sh

set -e

export OUTPUT_DIR="$PWD/output"

cd "$OUTPUT_DIR"
echo Formatting Disk Image
bin/bmfs baremetal-os.img initialize 128M
bin/bmfs baremetal-os.img mkdir programs
echo Writing Master Boot Record
dd if="system/bmfs_mbr.sys" of="baremetal-os.img" bs=512 conv=notrunc
