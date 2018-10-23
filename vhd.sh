#!/bin/sh

set -e
set -u

export OUTPUT_DIR="$PWD/output"

qemu-img convert -O vmdk "$OUTPUT_DIR/baremetal-os.img" "$OUTPUT_DIR/BareMetal_OS.vhd"
