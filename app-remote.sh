#!/bin/bash

set -e
set -u

top="${PWD}"

if [ ! -e "src/external" ]; then
	mkdir "src/external"
fi

url="$1"
dst=src/external/`basename $1`

if [ -e "$dst" ]; then
	cd $dst
	git pull origin master
else
	git clone "$url" "$dst"
	cd "$dst"
fi

if [ -e "build.sh" ]; then
	./build.sh
fi

for app in *.app; do
	"${top}/output/bin/bmfs" --disk "${top}/output/baremetal-os.img" --offset 32KiB rm -f Applications/$app
	"${top}/output/bin/bmfs" --disk "${top}/output/baremetal-os.img" --offset 32KiB cp $app Applications/$app
done
