#!/bin/sh

set -u
set -e

output_dir="${PWD}/output"

./scripts/update-submodule.sh "src/newlib"

cd src/newlib
./setup.sh --prefix "${output_dir}"
./install.sh
