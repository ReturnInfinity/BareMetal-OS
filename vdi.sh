#!/bin/sh

cd bin
qemu-img convert -O vdi bmfs.image BareMetal_OS.vdi
dd if=VDI_UUID.bin of=bin/BareMetal_OS.vdi count=1 bs=512 conv=notrunc

