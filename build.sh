#!/bin/bash

set -e
set -u

export EXEC_DIR="$PWD"
export OUTPUT_DIR="$EXEC_DIR/sys"

function build_dir {
	echo "Building $1..."
	cd "$1"
	if [ -e "build.sh" ]; then
		./build.sh
	fi
	if [ -e "install.sh" ]; then
		./install.sh
	fi
	if [ -e "Makefile" ]; then
		make --quiet
	fi
	cd "$EXEC_DIR"
}

build_dir "src/Pure64"
build_dir "src/BareMetal"
build_dir "src/BareMetal-Monitor"
build_dir "src/BMFS"

mv "src/Pure64/bin/mbr.sys" "${OUTPUT_DIR}/mbr.sys"
mv "src/Pure64/bin/multiboot.sys" "${OUTPUT_DIR}/multiboot.sys"
mv "src/Pure64/bin/multiboot2.sys" "${OUTPUT_DIR}/multiboot2.sys"
mv "src/Pure64/bin/pure64.sys" "${OUTPUT_DIR}/pure64.sys"
mv "src/Pure64/bin/pure64-debug.txt" "${OUTPUT_DIR}/pure64-debug.txt"
mv "src/Pure64/bin/pxestart.sys" "${OUTPUT_DIR}/pxestart.sys"
mv "src/Pure64/bin/uefi.sys" "${OUTPUT_DIR}/uefi.sys"
mv "src/BareMetal/bin/kernel.sys" "${OUTPUT_DIR}/kernel.sys"
mv "src/BareMetal/bin/kernel-debug.txt" "${OUTPUT_DIR}/kernel-debug.txt"
mv "src/BareMetal-Monitor/bin/monitor.bin" "${OUTPUT_DIR}/monitor.bin"
mv "src/BareMetal-Monitor/bin/monitor-debug.txt" "${OUTPUT_DIR}/monitor-debug.txt"
mv "src/BMFS/bin/bmfs" "${OUTPUT_DIR}/bmfs"
