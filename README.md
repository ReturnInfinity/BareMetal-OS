# BareMetal OS

Build scripts for BareMetal OS and its related utilities - The easiest way to create a BareMetal OS environment. These scripts will download and compile all of the components needed for using BareMetal OS.


## Prerequisites

These scripts depend on a Debian-based Linux system like [Ubuntu](https://https://www.ubuntu.com/download/desktop) or [Elementary](https://elementary.io/).

- NASM (Assembly compiler) is required to build the loader and kernel, as well as the apps written in Assembly.
- QEMU (computer emulator) is required if you plan on running the OS for quick testing.
- GCC (C compiler) is required for building C/C++ applications.
- Git is used for pulling the software from GitLab.

In Linux this can be completed with the following command:

	sudo apt install nasm qemu gcc git


## Initial configuration

	git clone https://github.com/ReturnInfinity/BareMetal-OS.git
	cd BareMetal-OS
	./setup.sh

setup.sh automatically runs the build and install scripts


## Rebuilding the source code

	./build.sh


## Installing to the disk image

	./install.sh


## Test the install with QEMU

	./run.sh


## Test the install with Bochs

Bochs does not support SATA drives so this is only useful for debugging the kernel. You will need `bochs` and `bochs-x` installed.

	bochs -f bochs.cfg


## Build a VMDK disk image for VMware

	./vmdk.sh


## Build a VDI disk image for VirtualBox

	./vdi.sh

The VDI script rewrites the disk ID of the VDI file to avoid the disk warning in VirtualBox.



// EOF
