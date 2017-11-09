#!/bin/sh

set -u
set -e

export OUTPUT_DIR="$PWD/output"

nasm -Isrc/Coreutils/ src/Coreutils/$1.asm -o "$OUTPUT_DIR/apps/$1.app"
cd "$OUTPUT_DIR"
bin/bmfs baremetal-os.img delete $1.app
bin/bmfs baremetal-os.img create $1.app 2
bin/bmfs baremetal-os.img write $1.app "$OUTPUT_DIR/apps/$1.app"
cd ..
