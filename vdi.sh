#!/bin/sh

set -e
set -u

export OUTPUT_DIR="$PWD/output"

qemu-img convert -O vdi "$OUTPUT_DIR/baremetal-os.img" "$OUTPUT_DIR/BareMetal_OS.vdi"

dd if=VDI_UUID.bin of="$OUTPUT_DIR/BareMetal_OS.vdi" count=1 bs=512 conv=notrunc

