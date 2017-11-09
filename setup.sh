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

git submodule update --init --recursive

./build.sh
./format.sh
./install.sh
