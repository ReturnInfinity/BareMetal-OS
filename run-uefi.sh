#!/bin/bash

qemu-system-x86_64 -bios sys/OVMF.fd -net none -drive format=raw,file=fat:rw:sys/drive -monitor telnet:localhost:8086,server,nowait
