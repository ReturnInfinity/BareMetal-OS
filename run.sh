#!/bin/bash
# from http://unix.stackexchange.com/questions/9804/how-to-comment-multi-line-commands-in-shell-scripts

cmd=( qemu-system-x86_64
	-machine q35
# Window title in graphics mode
	-name "BareMetal OS"
# Boot a multiboot kernel file
#	-kernel ./boot.bin
# Enable a supported NIC
	-net nic,model=e1000,macaddr=10:11:12:13:14:15
	-net user
# Amount of CPU cores
	-smp 2
# Amount of memory in Megabytes
	-m 256
# Disk configuration
	-drive id=disk0,file="sys/disk.img",if=none,format=raw
	-device ahci,id=ahci
	-device ide-hd,drive=disk0,bus=ahci.0
#	-drive id=disk1,file="sys/disk1.img",if=none,format=raw
#	-device nvme,serial=OMG-NVME,drive=disk1
# Ouput network to file
#	-net dump,file=net.pcap
# Output serial to file
	-serial file:"sys/serial.log"
# Enable monitor mode
	-monitor telnet:localhost:8086,server,nowait
# Enable GDB debugging
	-s
# Wait for GDB before starting execution
#	-S
)

#execute the cmd string
"${cmd[@]}"
