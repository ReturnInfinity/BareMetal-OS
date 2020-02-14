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

function update_file {
	mv "$1" "$2"
}

build_dir "src/Pure64"
build_dir "src/BareMetal"
build_dir "src/BareMetal-Monitor"
build_dir "src/BMFS"

update_file "src/Pure64/bin/mbr.sys" "${OUTPUT_DIR}/mbr.sys"
update_file "src/Pure64/bin/multiboot.sys" "${OUTPUT_DIR}/multiboot.sys"
update_file "src/Pure64/bin/multiboot2.sys" "${OUTPUT_DIR}/multiboot2.sys"
update_file "src/Pure64/bin/pure64.sys" "${OUTPUT_DIR}/pure64.sys"
update_file "src/Pure64/bin/pxestart.sys" "${OUTPUT_DIR}/pxestart.sys"
update_file "src/BareMetal/bin/kernel.sys" "${OUTPUT_DIR}/kernel.sys"
update_file "src/BareMetal/bin/kernel-debug.txt" "${OUTPUT_DIR}/kernel-debug.txt"
update_file "src/BareMetal-Monitor/bin/monitor.bin" "${OUTPUT_DIR}/monitor.bin"
update_file "src/BareMetal-Monitor/bin/monitor-debug.txt" "${OUTPUT_DIR}/monitor-debug.txt"
update_file "src/BMFS/bin/bmfs" "${OUTPUT_DIR}/bmfs"
