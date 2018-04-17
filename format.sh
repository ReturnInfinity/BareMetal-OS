#!/bin/sh

set -e

export OUTPUT_DIR="$PWD/output"

cd "$OUTPUT_DIR"
bin/bmfs --offset 32KiB --disk baremetal-os.img format --force --size 128M
bin/bmfs --offset 32KiB --disk baremetal-os.img mkdir /bin /sbin /root
