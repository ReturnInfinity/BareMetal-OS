#!/bin/sh

cd bin
qemu-system-x86_64 -vga std -smp 8 -m 256 -drive id=disk,file=bmfs.image,if=none,format=raw -device ahci,id=ahci -device ide-drive,drive=disk,bus=ahci.0 -name "BareMetal OS" -net nic,model=i82551 $*
