#!/bin/sh

qemu-system-x86_64 -smp 8 -m 256 -drive id=disk,file=bmfs.image,if=none -device ahci,id=ahci -device ide-drive,drive=disk,bus=ahci.0 -name "BareMetal OS"
