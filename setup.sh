#!/bin/bash

set -o errexit
set -u

mkdir -p bin

git submodule update --init --recursive

./build.sh
./format.sh
./install.sh
