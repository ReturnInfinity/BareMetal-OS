#!/bin/bash

set -o errexit
set -u

export OUTPUT_DIR="$PWD/output"

mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/apps"
mkdir -p "$OUTPUT_DIR/bin"
mkdir -p "$OUTPUT_DIR/include"
mkdir -p "$OUTPUT_DIR/lib"
mkdir -p "$OUTPUT_DIR/system"

function init_submodule {
	echo "Updating $1"
	git submodule update --init --recursive $1
}

init_submodule "src/Pure64"
init_submodule "src/kernel"
init_submodule "src/BMFS"
init_submodule "src/Alloy"
init_submodule "src/Examples"

./build.sh
./format.sh
./install.sh
