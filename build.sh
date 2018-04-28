#!/bin/bash

set -e
set -u

export OUTPUT_DIR="$PWD/output"
export C_INCLUDE_PATH="$PWD/output/include"

export ALLOY_WITH_BAREMETAL=1

export BMFS_INCLUDE_DIR="$OUTPUT_DIR/include"
export BMFS_LIBRARY="$OUTPUT_DIR/lib/libbmfs.a"

export BAREMETAL_LIBC_INCLUDE_DIR="$OUTPUT_DIR/include"
export BAREMETAL_LIBC_LIBRARY="$OUTPUT_DIR/lib/libc.a"

export PREFIX="$OUTPUT_DIR"

function build_dir {
	echo "Entering $PWD/$1"
	cd "$1"
	if [ -e "build_x86-64.sh" ]; then
		./build_x86-64.sh
	fi
	if [ -e "build.sh" ]; then
		./build.sh
	fi
	if [ -e "install.sh" ]; then
		./install.sh
	fi
	cd "../.."
}

function update_file {
	echo "Updating $2"
	cp --update "$1" "$2"
}

build_dir "src/BMFS"
build_dir "src/AlloyLoader"
build_dir "src/Alloy"
build_dir "src/Pure64"
build_dir "src/kernel"

update_file "src/AlloyLoader/alloy-loader.bin" "${OUTPUT_DIR}/system/loader.bin"
update_file "src/Alloy/src/alloy" "${OUTPUT_DIR}/system/alloy"
update_file "src/Alloy/src/alloy.bin" "${OUTPUT_DIR}/system/alloy.bin"
update_file "src/Pure64/bmfs_mbr.sys" "${OUTPUT_DIR}/system/bmfs_mbr.sys"
update_file "src/Pure64/pure64.sys" "${OUTPUT_DIR}/system/pure64.sys"
update_file "src/kernel/src/x86-64/kernel.elf" "${OUTPUT_DIR}/system/kernel.elf"
update_file "src/kernel/src/x86-64/kernel.bin" "${OUTPUT_DIR}/system/kernel.bin"
