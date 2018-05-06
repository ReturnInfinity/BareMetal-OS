#!/bin/sh

set -o errexit
set -u

export OUTPUT_DIR="$PWD/output"

mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/apps"
mkdir -p "$OUTPUT_DIR/bin"
mkdir -p "$OUTPUT_DIR/include"
mkdir -p "$OUTPUT_DIR/lib"
mkdir -p "$OUTPUT_DIR/system"

./scripts/update-submodule.sh "src/Pure64"
./scripts/update-submodule.sh "src/kernel"
./scripts/update-submodule.sh "src/BMFS"
./scripts/update-submodule.sh "src/Alloy"
./scripts/update-submodule.sh "src/Examples"

./build.sh
./format.sh
./install.sh
