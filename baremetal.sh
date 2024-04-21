#!/bin/bash

set -e
export EXEC_DIR="$PWD"
export OUTPUT_DIR="$EXEC_DIR/sys"

function baremetal_clean {
	rm -rf src
	rm -rf sys
}

function baremetal_setup {
	baremetal_clean

	mkdir src

	echo "Pulling code from GitHub..."
	cd src
	git clone https://github.com/ReturnInfinity/Pure64.git -q
	git clone https://github.com/ReturnInfinity/BareMetal.git -q
	git clone https://github.com/ReturnInfinity/BareMetal-Monitor.git -q
	git clone https://github.com/ReturnInfinity/BMFS.git -q
	git clone https://github.com/ReturnInfinity/BareMetal-Demo.git -q
	cd ..

	echo "Downloading UEFI firmware..."
	cd sys
	if [ -x "$(command -v curl)" ]; then
		curl -s -o OVMF.fd https://cdn.download.clearlinux.org/image/OVMF.fd
	else
		wget -q https://cdn.download.clearlinux.org/image/OVMF.fd
	fi
	cd ..

	echo "Creating disk images..."
	cd sys
	dd if=/dev/zero of=bmfs.img count=128 bs=1048576 > /dev/null 2>&1
	dd if=/dev/zero of=null.bin count=8 bs=1 > /dev/null 2>&1
	mformat -t 128 -h 2 -n 1024 -C -F -i fat32.img
	mmd -i fat32.img ::/EFI
	mmd -i fat32.img ::/EFI/BOOT
	echo "\EFI\BOOT\BOOTX64.EFI" > startup.nsh
	mcopy -i fat32.img startup.nsh ::/
	rm startup.nsh
	cd ..

	echo "Preparing dependancies..."
	cd src/BareMetal-Monitor
	./setup.sh
	cd ../..
	cd src/BareMetal-Demo
	./setup.sh
	cd ../..

	baremetal_build

	cd sys
	./bmfs bmfs.img format
	cd ..

	baremetal_install

	echo Done!
}

function build_dir {
	echo "Building $1..."
	cd "$1"
	if [ -e "build.sh" ]; then
		./build.sh
	fi
	if [ -e "install.sh" ]; then
		./install.sh
	fi
	if [ -e "Makefile" ]; then
		make --quiet
	fi
	cd "$EXEC_DIR"
}

function baremetal_build {
	build_dir "src/Pure64"
	build_dir "src/BareMetal"
	build_dir "src/BareMetal-Monitor"
	build_dir "src/BMFS"
	build_dir "src/BareMetal-Demo"

	mv "src/Pure64/bin/pure64.sys" "${OUTPUT_DIR}/pure64.sys"
	mv "src/Pure64/bin/pure64-debug.txt" "${OUTPUT_DIR}/pure64-debug.txt"
	mv "src/Pure64/bin/uefi.sys" "${OUTPUT_DIR}/uefi.sys"
	mv "src/Pure64/bin/uefi-debug.txt" "${OUTPUT_DIR}/uefi-debug.txt"
	mv "src/Pure64/bin/bios.sys" "${OUTPUT_DIR}/bios.sys"
	mv "src/Pure64/bin/bios-debug.txt" "${OUTPUT_DIR}/bios-debug.txt"
	mv "src/BareMetal/bin/kernel.sys" "${OUTPUT_DIR}/kernel.sys"
	mv "src/BareMetal/bin/kernel-debug.txt" "${OUTPUT_DIR}/kernel-debug.txt"
	mv "src/BareMetal-Monitor/bin/monitor.bin" "${OUTPUT_DIR}/monitor.bin"
	mv "src/BareMetal-Monitor/bin/monitor-debug.txt" "${OUTPUT_DIR}/monitor-debug.txt"
	mv "src/BMFS/bin/bmfs" "${OUTPUT_DIR}/bmfs"
}

function baremetal_install {
	cd "$OUTPUT_DIR"
	echo "Building OS image..."

	if [ "$#" -ne 1 ]; then
		cat pure64.sys kernel.sys monitor.bin > software.sys
	else
		cat pure64.sys kernel.sys $1 > software.sys
	fi

	# Copy software to BMFS for BIOS loading
	dd if=software.sys of=bmfs.img bs=4096 seek=2 conv=notrunc > /dev/null 2>&1

	# Prep UEFI loader
	cp uefi.sys BOOTX64.EFI
	dd if=software.sys of=BOOTX64.EFI bs=4096 seek=1 conv=notrunc > /dev/null 2>&1

	# Copy UEFI boot to disk image
	mcopy -oi fat32.img BOOTX64.EFI ::/EFI/BOOT/BOOTX64.EFI
	# Copy first 3 bytes of MBR (jmp and nop)
	dd if=bios.sys of=fat32.img bs=1 count=3 conv=notrunc > /dev/null 2>&1
	# Copy MBR code starting at offset 90
	dd if=bios.sys of=fat32.img bs=1 skip=90 seek=90 count=356 conv=notrunc > /dev/null 2>&1

	# Create FAT32/BMFS hybrid disk
	cat fat32.img bmfs.img > baremetal_os.img

	cd ..
}

function baremetal_demos {
	echo "Copying demos to disk image..."
	cd src/BareMetal-Demo/bin
	cp *.app ../../../sys/
	cd ../../../sys/
	./bmfs bmfs.img write hello.app
	./bmfs bmfs.img write ethtest.app
	./bmfs bmfs.img write sysinfo.app
	./bmfs bmfs.img write euler1.app
	./bmfs bmfs.img write smptest.app
	if [ "$(uname)" != "Darwin" ]; then
		./bmfs bmfs.img write helloc.app
		./bmfs bmfs.img write gavare.app
	fi
}

function baremetal_run {
	echo "Starting QEMU..."
	cmd=( qemu-system-x86_64
		-machine q35
		-name "BareMetal OS"
		-m 256
		-smp sockets=1,cpus=4

	# Network
		-netdev socket,id=testnet,listen=:1234
	# On a second machine uncomment the line below, comment the line above, and change the mac
	#	-netdev socket,id=testnet,connect=127.0.0.1:1234
	# Use one device type.
		-device e1000,netdev=testnet,mac=10:11:12:13:14:15 # Intel 82540EM
	#	-device e1000e,netdev=testnet,mac=10:11:12:13:14:15 # Intel 82574L
	# VIRTIO
	#	-device virtio-net-pci,netdev=testnet,mac=10:11:12:13:14:15 #,disable-legacy=on,disable-modern=false
	# Output network traffic to file
	#	-object filter-dump,id=testnet,netdev=testnet,file=net.pcap

	# Disk configuration. Use one controller.
		-drive id=disk0,file="sys/baremetal_os.img",if=none,format=raw
	# NVMe
	#	-device nvme,serial=12345678,drive=disk0
	# AHCI
		-device ahci,id=ahci
		-device ide-hd,drive=disk0,bus=ahci.0
	# VIRTIO
	#	-device virtio-blk,drive=disk0 #,disable-legacy=on,disable-modern=false
	# IDE
	#	-device ide-hd,drive=disk0,bus=ide.0

	# Serial configuration
	# Output serial to file
		-serial file:"sys/serial.log"
	# Output serial to console
	#	-chardev stdio,id=char0,logfile="sys/serial.log",signal=off
	#	-serial chardev:char0

	# Debugging
	# Enable monitor mode
	#	-monitor telnet:localhost:8086,server,nowait
	# Enable GDB debugging
	#	-s
	# Wait for GDB before starting execution
	#	-S
	# Trace options
	#	-trace "virt*"
	#	-trace "apic*"
	#	-trace "msi*"
	#	-d trace:memory_region_ops_* # Or read/write
	# Prevent QEMU for resetting (triple fault)
	#	-no-shutdown -no-reboot
	)

	#execute the cmd string
	"${cmd[@]}"
}

function baremetal_run-uefi {
	echo "Starting QEMU..."
	cmd=( qemu-system-x86_64
		-machine q35
		-name "BareMetal OS (UEFI)"
		-bios sys/OVMF.fd
		-m 256
		-smp sockets=1,cpus=4
	#	-cpu qemu64,pdpe1gb # Support for 1GiB pages

	# Network
		-netdev socket,id=testnet,listen=:1234
	# On a second machine uncomment the line below, comment the line above, and change the mac
	#	-netdev socket,id=testnet,connect=127.0.0.1:1234
	# Use one device type.
		-device e1000,netdev=testnet,mac=10:11:12:13:14:15 # Intel 82540EM
	#	-device e1000e,netdev=testnet,mac=10:11:12:13:14:15 # Intel 82574L
	# Output network traffic to file
	#	-net dump,file=net.pcap

	# Disk configuration. Use one controller.
		-drive id=disk0,file="sys/baremetal_os.img",if=none,format=raw
	# NVMe
	#	-device nvme,serial=12345678,drive=disk0
	# AHCI
		-device ahci,id=ahci
		-device ide-hd,drive=disk0,bus=ahci.0
	# IDE
	#	-device ide-hd,drive=disk0,bus=ide.0

	# Output serial to file
		-serial file:"sys/serial.log"

	# Debugging
	# Enable monitor mode
	#	-monitor telnet:localhost:8086,server,nowait
	# Enable GDB debugging
	#	-s
	# Wait for GDB before starting execution
	#	-S
	# Prevent QEMU for resetting (triple fault)
	#	-no-shutdown -no-reboot
	)

	#execute the cmd string
	"${cmd[@]}"
}

function baremetal_vdi {
	echo "Creating VDI image..."
	VDI="3c3c3c2051454d5520564d205669727475616c204469736b20496d616765203e3e3e0a00000000000000000000000000000000000000000000000000000000007f10dabe0100010080010000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000004000000000000000000000000000000020000000000000000000800000000000010000000000080000000020000000403020106050807090a0b0c0d0e0f10ab1caf6562222e4d9fd24b5083cb4c5d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"

	qemu-img convert -O vdi "$OUTPUT_DIR/baremetal_os.img" "$OUTPUT_DIR/BareMetal_OS.vdi"

	echo $VDI > VDI_UUID.hex
	xxd -r -p VDI_UUID.hex VDI_UUID.bin

	dd if=VDI_UUID.bin of="$OUTPUT_DIR/BareMetal_OS.vdi" count=1 bs=512 conv=notrunc > /dev/null 2>&1

	rm VDI_UUID.hex
	rm VDI_UUID.bin
}

function baremetal_vmdk {
	echo "Creating VMDK image..."
	qemu-img convert -O vmdk "$OUTPUT_DIR/baremetal_os.img" "$OUTPUT_DIR/BareMetal_OS.vmdk"
}

function baremetal_bnr {
	baremetal_build
	baremetal_install
	baremetal_run
}

function baremetal_bnr-uefi {
	baremetal_build
	baremetal_install
	baremetal_run-uefi
}

function baremetal_help {
	echo "BareMetal-OS Script"
	echo "Available commands:"
	echo "clean    - Clean the src and bin folders"
	echo "setup    - Clean and setup"
	echo "build    - Build source code"
	echo "install  - Install binary to disk image"
	echo "demos    - Install demos to disk image"
	echo "run      - Run the OS via QEMU"
	echo "run-uefi - Run the OS via QEMU in UEFI mode"
	echo "vdi      - Generate VDI disk image for VirtualBox"
	echo "vmdk     - Generate VMDK disk image for VMware"
	echo "bnr      - Build 'n Run"
	echo "bnr-uefi - Build 'n Run in UEFI mode"
}

if [ $# -eq 0 ]; then
	baremetal_help
elif [ $# -eq 1 ]; then
	if [ "$1" == "setup" ]; then
		baremetal_setup
	elif [ "$1" == "clean" ]; then
		baremetal_clean
	elif [ "$1" == "build" ]; then
		baremetal_build
	elif [ "$1" == "install" ]; then
		baremetal_install
	elif [ "$1" == "help" ]; then
		baremetal_help
	elif [ "$1" == "run" ]; then
		baremetal_run
	elif [ "$1" == "run-uefi" ]; then
		baremetal_run-uefi
	elif [ "$1" == "demos" ]; then
		baremetal_demos
	elif [ "$1" == "vdi" ]; then
		baremetal_vdi
	elif [ "$1" == "bnr" ]; then
		baremetal_bnr
	elif [ "$1" == "bnr-uefi" ]; then
		baremetal_bnr-uefi
	else
		echo "Invalid argument '$1'"
	fi
elif [ $# -eq 2 ]; then
	if [ "$1" == "install" ]; then
		baremetal_install $2
	fi
fi
