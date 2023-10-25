#!/bin/bash
# from http://unix.stackexchange.com/questions/9804/how-to-comment-multi-line-commands-in-shell-scripts

cmd=( qemu-system-x86_64
	-machine q35
	-name "BareMetal OS"
	-m 256 # RAM in Megabytes
	-smp sockets=1,cpus=4

# Network
	-netdev socket,id=testnet,listen=:1234
# On a second machine uncomment the line below, comment the line above, and change the mac
#       -netdev socket,id=testnet,connect=127.0.0.1:1234
# Use one device type.
	-device e1000,netdev=testnet,mac=10:11:12:13:14:15 # Intel 82540EM
#	-device e1000e,netdev=testnet,mac=10:11:12:13:14:15 # Intel 82574L
# Output network traffic to file
#	-net dump,file=net.pcap

# Disk configuration. Use one controller.
	-drive id=disk0,file="sys/disk.img",if=none,format=raw
# IDE
#	-device ide-hd,drive=disk0,bus=ide.0
# AHCI
	-device ahci,id=ahci
	-device ide-hd,drive=disk0,bus=ahci.0
# NVMe
#	-device nvme,serial=12345678,drive=disk0

# Output serial to file
	-serial file:"sys/serial.log"

# Debugging
# Enable monitor mode
#	-monitor telnet:localhost:8086,server,nowait
# Enable GDB debugging
#	-s
# Wait for GDB before starting execution
#	-S
)

#execute the cmd string
"${cmd[@]}"
