#!/bin/sh

set -e

export OUTPUT_DIR="$PWD/output"

cd "$OUTPUT_DIR"
echo Writing Pure64+Software
cat "$OUTPUT_DIR/system/pure64.sys" \
    "$OUTPUT_DIR/system/kernel.sys" \
    "$OUTPUT_DIR/system/alloy.bin" > "$OUTPUT_DIR/system/software.sys"
dd if="$OUTPUT_DIR/system/software.sys" of="$OUTPUT_DIR/baremetal-os.img" bs=512 seek=16 conv=notrunc
