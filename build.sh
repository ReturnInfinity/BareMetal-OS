#!/bin/bash

set -e
set -u

export OUTPUT_DIR="$PWD/sys"

function build_dir {
	echo "Entering $PWD/$1"
	cd "$1"
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
	mv "$1" "$2"
}

build_dir "src/Pure64"
build_dir "src/BareMetal"

update_file "src/Pure64/bin/mbr.sys" "${OUTPUT_DIR}/mbr.sys"
update_file "src/Pure64/bin/multiboot.sys" "${OUTPUT_DIR}/multiboot.sys"
update_file "src/Pure64/bin/multiboot2.sys" "${OUTPUT_DIR}/multiboot2.sys"
update_file "src/Pure64/bin/pure64.sys" "${OUTPUT_DIR}/pure64.sys"
update_file "src/Pure64/bin/pxestart.sys" "${OUTPUT_DIR}/pxestart.sys"
update_file "src/BareMetal/bin/kernel.sys" "${OUTPUT_DIR}/kernel.sys"
update_file "src/BareMetal/bin/kernel-debug.txt" "${OUTPUT_DIR}/kernel-debug.txt"


