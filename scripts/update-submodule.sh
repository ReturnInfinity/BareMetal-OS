#!/bin/sh

set -e
set -u

echo "Updating $1"
git submodule init "$1"
git submodule update "$1"
