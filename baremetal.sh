#!/bin/bash

set +e
export EXEC_DIR="$PWD"
export OUTPUT_DIR="$EXEC_DIR/sys"

# see if APPS was defined
# eg APPS="hello.app systest.app" ./baremetal.sh setup
# if APPS is empty then supply the default apps
# this allows the user to build their own apps and have
# them installed in the BMFS
if [ "x$APPS" = x ]; then
	APPS="hello.app sysinfo.app systest.app uitest.app"
	if [ "$(uname)" != "Darwin" ]; then
		APPS="$APPS helloc.app raytrace.app minIP.app cube3d.app
			color-plasma.app 3d-model-loader.app"
	fi
fi
# see if BMFS_SIZE was defined for custom disk sizes
if [ "x$BMFS_SIZE" = x ]; then
	BMFS_SIZE=128
fi

function baremetal_clean {
	rm -rf src
	rm -rf sys
}

function baremetal_setup {
	echo -e "BareMetal OS Setup\n==================="
	baremetal_clean

	mkdir src
	mkdir sys

	echo -n "Pulling code from GitHub... "
	cd src
	git clone https://github.com/ReturnInfinity/Pure64.git -q
	git clone https://github.com/ReturnInfinity/BareMetal.git -q
	git clone https://github.com/ReturnInfinity/BareMetal-Monitor.git -q
	git clone https://github.com/ReturnInfinity/BMFS.git -q
	git clone https://github.com/ReturnInfinity/BareMetal-Demo.git -q
	cd ..
	echo "OK"

	echo -n "Downloading UEFI firmware... "
	cd sys
	if [ -x "$(command -v curl)" ]; then
		curl -s -o OVMF.fd https://cdn.download.clearlinux.org/image/OVMF.fd
	else
		wget -q https://cdn.download.clearlinux.org/image/OVMF.fd
	fi
	cd ..
	echo "OK"

	echo -n "Preparing dependancies... "
	cd src/BareMetal-Monitor
	./setup.sh
	cd ../..
	cd src/BareMetal-Demo
	./setup.sh
	cd ../..
	echo "OK"

	baremetal_build

	echo -n "Copying software to disk image... "
	baremetal_install
	baremetal_install_demos
	echo "OK"

	echo -e "\nSetup Complete. Use './baremetal.sh run' to start."
}

# Initialize disk images
function init_imgs { # arg 1 is BMFS size in MiB
	echo -n "Creating disk image files... "
	cd sys
	dd if=/dev/zero of=bmfs.img count=$1 bs=1048576 > /dev/null 2>&1
	dd if=/dev/zero of=bmfs-lite.img count=1 bs=1048576 > /dev/null 2>&1
	if [ -x "$(command -v mformat)" ]; then
		mformat -t 128 -h 2 -s 1024 -C -F -i fat32.img
		mmd -i fat32.img ::/EFI > /dev/null 2>&1
		mmd -i fat32.img ::/EFI/BOOT > /dev/null 2>&1
		retVal=$?
		if [ $retVal -ne 0 ]; then
			echo -n "no UEFI support (due to bad mtools), "
		fi
		echo "\EFI\BOOT\BOOTX64.EFI" > startup.nsh
		mcopy -i fat32.img startup.nsh ::/
		rm startup.nsh
	else
		dd if=/dev/zero of=fat32.img count=128 bs=1048576 > /dev/null 2>&1
	fi
	echo "OK"

	cd ..
}

function update_dir {
	echo "Updating $1..."
	cd "$1"
	git pull -q
	cd "$EXEC_DIR"
}

function baremetal_update {
	git pull -q
	baremetal_src_check
	update_dir "src/Pure64"
	update_dir "src/BareMetal"
	update_dir "src/BareMetal-Monitor"
	update_dir "src/BMFS"
	update_dir "src/BareMetal-Demo"
}

function build_dir {
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
	mv bin/* "${OUTPUT_DIR}"
	cd "$EXEC_DIR"
}

# Build the source code and create the software files
function baremetal_build {
	baremetal_src_check
	echo -n "Assembling source code... "
	build_dir "src/Pure64"
	build_dir "src/BareMetal"
	build_dir "src/BareMetal-Monitor"
	build_dir "src/BMFS"
	build_dir "src/BareMetal-Demo"
	echo "OK"

	init_imgs $BMFS_SIZE

	cd "$OUTPUT_DIR"

	# Inject a program binary into to the kernel (ORG 0x001E0000)
	if [ "$#" -ne 1 ]; then
		cat pure64-bios.sys kernel.sys monitor.bin > software-bios.sys
		cat pure64-uefi.sys kernel.sys monitor.bin > software-uefi.sys
	else
		if [ -f $1 ]; then
			cat pure64-bios.sys kernel.sys $1 > software-bios.sys
			cat pure64-uefi.sys kernel.sys $1 > software-uefi.sys
		else
			echo "$1 does not exist. Skipping binary injection"
		fi
	fi

	# Copy software to BMFS for BIOS loading
	dd if=software-bios.sys of=bmfs.img bs=4096 seek=2 conv=notrunc > /dev/null 2>&1

	# Prep UEFI loader
	cp uefi.sys BOOTX64.EFI
	dd if=software-uefi.sys of=BOOTX64.EFI bs=4096 seek=1 conv=notrunc > /dev/null 2>&1
	dd if=bmfs-lite.img of=BOOTX64.EFI bs=1024 seek=64 conv=notrunc > /dev/null 2>&1

	dd if=/dev/zero of=floppy.img count=2880 bs=512 > /dev/null 2>&1

	echo -n "Formatting BMFS disk... "
	./bmfs bmfs.img format
	echo "OK"

	cd ..
}

# Install system software (boot sector, Pure64, kernel) to various storage images
function baremetal_install {
	baremetal_sys_check
	cd "$OUTPUT_DIR"

	# Copy UEFI boot to disk image
	if [ -x "$(command -v mcopy)" ]; then
		mcopy -oi fat32.img BOOTX64.EFI ::/EFI/BOOT/BOOTX64.EFI > /dev/null 2>&1
		retVal=$?
		if [ $retVal -ne 0 ]; then
			echo -n "no UEFI support (due to bad mtools), "
		fi
	fi

	# Copy first 3 bytes of MBR (jmp and nop)
	dd if=bios.sys of=fat32.img bs=1 count=3 conv=notrunc > /dev/null 2>&1
	# Copy MBR code starting at offset 90
	dd if=bios.sys of=fat32.img bs=1 skip=90 seek=90 count=356 conv=notrunc > /dev/null 2>&1
	# Copy Bootable flag (in case of no mtools)
	dd if=bios.sys of=fat32.img bs=1 skip=510 seek=510 count=2 conv=notrunc > /dev/null 2>&1

	# Create FAT32/BMFS hybrid disk
	cat fat32.img bmfs.img > baremetal_os.img

	# Create Floppy bootable system disk
	cat bios-floppy.sys software-bios.sys > floppy.sys
	dd if=floppy.sys of=floppy.img conv=notrunc > /dev/null 2>&1

	cd ..
}

# Copy demos to disk and RAM drive images, update file disk images
function baremetal_install_demos {
	baremetal_sys_check
	cd "$OUTPUT_DIR"

	# Build disk image
	for app in $APPS; do
		./bmfs bmfs.img write $app
	done

	# Build RAM drive image
	./bmfslite bmfs-lite.img initialize
	for app in $APPS; do
		./bmfslite bmfs-lite.img write $app
	done

	# Create FAT32/BMFS hybrid disk
	cat fat32.img bmfs.img > baremetal_os.img

	# Copy RAM drive image
	dd if=bmfs-lite.img of=BOOTX64.EFI bs=1024 seek=64 conv=notrunc > /dev/null 2>&1
	dd if=bmfs-lite.img of=floppy.img bs=1024 seek=64 conv=notrunc > /dev/null 2>&1

	# Copy UEFI boot + RAM Drive to disk image
	if [ -x "$(command -v mcopy)" ]; then
		mcopy -oi fat32.img BOOTX64.EFI ::/EFI/BOOT/BOOTX64.EFI > /dev/null 2>&1
		retVal=$?
		if [ $retVal -ne 0 ]; then
			echo -n "no UEFI support (due to bad mtools), "
		fi
	fi

	# Create FAT32/BMFS hybrid disk
	cat fat32.img bmfs.img > baremetal_os.img

	cd ..
}

function baremetal_run {
	baremetal_sys_check
	echo "Starting QEMU..."
	cmd=( qemu-system-x86_64
		-machine q35
		-name "BareMetal OS"
		-m 256
		-smp sockets=1,cpus=4

	# Network configuration. Use one controller.
		-netdev socket,id=testnet,listen=:1234
	# Intel 82540EM
		-device e1000,netdev=testnet,mac=10:11:12:08:25:40
	# Intel 82574L
	#	-device e1000e,netdev=testnet,mac=10:11:12:08:25:74
	# VIRTIO
	#	-device virtio-net-pci,netdev=testnet,mac=10:11:12:13:14:15 #,disable-legacy=on,disable-modern=false

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
	# Floppy
	#	-drive format=raw,file="sys/floppy.img",index=0,if=floppy

	# Serial configuration
	# Output serial to file
		-serial file:"sys/serial.log"
	# Output serial to console
	#	-chardev stdio,id=char0,logfile="sys/serial.log",signal=off
	#	-serial chardev:char0

	# Debugging
	# Enable monitor mode
		-monitor telnet:localhost:8086,server,nowait
	# Enable GDB debugging
	#	-s
	# Wait for GDB before starting execution
	#	-S
	# Output network traffic to file
	#	-object filter-dump,id=testnet,netdev=testnet,file=net.pcap
	# Trace options
	#	-trace "e1000e_core*"
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
	baremetal_sys_check
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
		-monitor telnet:localhost:8086,server,nowait
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

function baremetal_run_netclient {
	baremetal_sys_check
	# Make a copy of the latest disk image
	cp sys/baremetal_os.img sys/baremetal_os2.img
	# Start up a VM and connect to the first instance
	echo "Starting QEMU..."
	cmd=( qemu-system-x86_64
		-machine q35
		-name "BareMetal OS (Second Instance)"
		-m 256
		-smp sockets=1,cpus=4
		-netdev socket,id=testnet,connect=127.0.0.1:1234
		-device e1000,netdev=testnet,mac=10:11:12:13:CA:FE
		-drive id=disk0,file="sys/baremetal_os2.img",if=none,format=raw
		-device ahci,id=ahci
		-device ide-hd,drive=disk0,bus=ahci.0
	)
	"${cmd[@]}"
}

function baremetal_vdi {
	baremetal_sys_check
	echo "Creating VDI image..."
	VDI="3C3C3C2051454D5520564D205669727475616C204469736B20496D616765203E3E3E0A00000000000000000000000000000000000000000000000000000000007F10DABE010001008001000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000600000000000000000000000000000002000000000000000000100000000000001000000000000001000004000000AE8AA5DE02E79043BE0B20DA0E2863EC00D36EACC7B88D4AA988CF098BC1C90200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"

	qemu-img convert -O vdi "$OUTPUT_DIR/baremetal_os.img" "$OUTPUT_DIR/BareMetal_OS.vdi"

	echo $VDI > "$OUTPUT_DIR/VDI_UUID.hex"
	xxd -r -p "$OUTPUT_DIR/VDI_UUID.hex" "$OUTPUT_DIR/VDI_UUID.bin"

	dd if="$OUTPUT_DIR/VDI_UUID.bin" of="$OUTPUT_DIR/BareMetal_OS.vdi" count=1 bs=512 conv=notrunc > /dev/null 2>&1

	rm "$OUTPUT_DIR/VDI_UUID.hex"
	rm "$OUTPUT_DIR/VDI_UUID.bin"
}

function baremetal_vmdk {
	baremetal_sys_check
	echo "Creating VMDK image..."
	qemu-img convert -O vmdk "$OUTPUT_DIR/baremetal_os.img" "$OUTPUT_DIR/BareMetal_OS.vmdk"
}

function baremetal_bnr {
	baremetal_build
	baremetal_install
	baremetal_install_demos
	baremetal_run
}

function baremetal_bnr-uefi {
	baremetal_build
	baremetal_install
	baremetal_install_demos
	baremetal_run-uefi
}

function baremetal_app {
	baremetal_sys_check
	cd sys
	if [ -f $1 ]; then
		./bmfs bmfs.img format /force
		./bmfs bmfs.img write $1
		cat fat32.img bmfs.img > baremetal_os.img
		cd ..
		baremetal_run
	else
		echo "$1 does not exist."
		cd ..
	fi
}

function baremetal_help {
	echo "BareMetal-OS Script"
	echo "Available commands:"
	echo "clean    - Clean the src and bin folders"
	echo "setup    - Clean and setup"
	echo "update   - Pull in the latest code"
	echo "build    - Build source code"
	echo "install  - Install binary to disk image"
	echo "demos    - Install demos to disk image"
	echo "run      - Run the OS via QEMU"
	echo "run-uefi - Run the OS via QEMU in UEFI mode"
	echo "run-2    - Run a second instance of BareMetal for network testing"
	echo "vdi      - Generate VDI disk image for VirtualBox"
	echo "vmdk     - Generate VMDK disk image for VMware"
	echo "bnr      - Build 'n Run"
	echo "bnr-uefi - Build 'n Run in UEFI mode"
	echo "*.app    - Install and run an app"
}

function baremetal_src_check {
	if [ ! -d src ]; then
		echo "Files are missing. Please run './baremetal.sh setup' first."
		exit 1
	fi
}

function baremetal_sys_check {
	if [ ! -d sys ]; then
		echo "Files are missing. Please run './baremetal.sh setup' first."
		exit 1
	fi
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
	elif [ "$1" == "update" ]; then
		baremetal_update
	elif [ "$1" == "help" ]; then
		baremetal_help
	elif [ "$1" == "run" ]; then
		baremetal_run
	elif [ "$1" == "run-uefi" ]; then
		baremetal_run-uefi
	elif [ "$1" == "run-2" ]; then
		baremetal_run_netclient
	elif [ "$1" == "demos" ]; then
		baremetal_install_demos
	elif [ "$1" == "vdi" ]; then
		baremetal_vdi
	elif [ "$1" == "bnr" ]; then
		baremetal_bnr
	elif [ "$1" == "bnr-uefi" ]; then
		baremetal_bnr-uefi
	elif [[ "$*" == *".app"* ]]; then
		baremetal_app $1
	else
		echo "Invalid argument '$1'"
	fi
elif [ $# -eq 2 ]; then
	if [ "$1" == "build" ]; then
		baremetal_build $2
	elif [ "$1" == "install" ]; then
		baremetal_install $2
	fi
fi
