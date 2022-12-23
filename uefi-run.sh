#!/bin/bash
# from http://unix.stackexchange.com/questions/9804/how-to-comment-multi-line-commands-in-shell-scripts

cd sys
mformat -t 128 -h 2 -n 1024 -C -F -i fat.img
mmd -i fat.img ::/EFI
mmd -i fat.img ::/EFI/BOOT
mcopy -oi fat.img BOOTX64.EFI ::/EFI/BOOT/BOOTX64.EFI
echo "\EFI\BOOT\BOOTX64.EFI" > startup.nsh
mcopy -i fat.img startup.nsh ::/
cd ..

cmd=( qemu-system-x86_64
	-machine q35
	-name "BareMetal OS"
	-bios sys/OVMF.fd
	-m 64
	-smp sockets=1,cpus=4
	-device e1000,netdev=testnet,mac=10:11:12:13:14:15
	-netdev socket,id=testnet,listen=:1234
# On a second machine uncomment the line below, comment the line above, and change the mac
#       -netdev socket,id=testnet,connect=127.0.0.1:1234
# Disk configuration
# File system folder
#	-drive format=raw,file=fat:rw:sys/drive
# AHCI
	-drive id=disk0,file="sys/fat.img",if=none,format=raw
	-device ahci,id=ahci
	-device ide-hd,drive=disk0,bus=ahci.0
# NVMe
#	-drive id=disk1,file="sys/disk1.img",if=none,format=raw
#	-device nvme,drive=disk1
# Ouput network to file
#	-net dump,file=net.pcap
# Output serial to file
	-serial file:"sys/serial.log"
# Enable monitor mode
	-monitor telnet:localhost:8086,server,nowait
# Enable GDB debugging
#	-s
# Wait for GDB before starting execution
#	-S
)

#execute the cmd string
"${cmd[@]}"
