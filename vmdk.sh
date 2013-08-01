#!/bin/sh

cd bin
qemu-img convert -O vmdk bmfs.image BareMetal_OS.vmdk
