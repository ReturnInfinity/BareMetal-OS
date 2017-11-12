#!/bin/sh

set -e

export OUTPUT_DIR="$PWD/output"

cd "$OUTPUT_DIR"
bin/bmfs baremetal-os.img initialize 128M
bin/bmfs baremetal-os.img mkdir programs
