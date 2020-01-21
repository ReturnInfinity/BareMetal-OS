#!/bin/sh

set -e
set -u

export OUTPUT_DIR="$PWD/sys"

qemu-img convert -O vmdk "$OUTPUT_DIR/disk.img" "$OUTPUT_DIR/BareMetal_OS.vmdk"
