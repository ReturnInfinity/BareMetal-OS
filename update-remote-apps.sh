#!/bin/bash

if [ ! -e "src/external" ]; then
	echo "No external apps exist yet."
	exit 1
fi

top=${PWD}

for appDir in src/external/*; do
	cd "$appDir"
	if [ -e "build.sh" ]; then
		./build.sh
	fi
	for app in *.app; do
		${top}/output/bin/bmfs --disk ${top}/output/baremetal-os.img --offset 32KiB rm -f Applications/$app
		${top}/output/bin/bmfs --disk ${top}/output/baremetal-os.img --offset 32KiB cp $app Applications/$app
	done
	cd "${top}"
done
