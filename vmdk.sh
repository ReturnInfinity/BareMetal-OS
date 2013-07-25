#!/bin/sh

cd build
qemu-img convert -O vmdk bmfs.image BareMetal_OS.vmdk
