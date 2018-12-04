# This project has been archived and marked as read-only. The BareMetal OS repo is now hosted on [GitLab](https://gitlab.com/ReturnInfinity/BareMetal-OS).

BareMetal OS build scripts
==========================

The easiest way to create a BareMetal OS build environment. These scripts will download and compile all of the components needed for using BareMetal OS.

[![Join the chat at https://gitter.im/ReturnInfinity/BareMetal-OS](https://badges.gitter.im/ReturnInfinity/BareMetal-OS.svg)](https://gitter.im/ReturnInfinity/BareMetal-OS?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/ReturnInfinity/BareMetal-OS.svg?branch=master)](https://travis-ci.org/ReturnInfinity/BareMetal-OS)


Prerequisites
-------------

NASM (Assembly compiler) is required to build the loader and OS, as well as the apps writen in Assembly. QEMU (computer emulator) is required if you plan on running the OS for quick testing. GCC (C compiler) is required for building the BMFS disk utility, the C applications, as well as Newlib. Git is used for pulling the software from GitHub. FreeType is used for rendering the font glyphs in Alloy.

In Ubuntu this can be completed with the following command:

	sudo apt-get install nasm qemu gcc git libfreetype6-dev pkg-config

There are additional dependencies if you are planning on compiling Newlib. They can be installed with the following command:

	sudo apt-get install autoconf automake libtool sed gawk bison flex m4 texinfo texi2html unzip make

If you want to build programs written in D you also need the ldc2 compiler.


Initial configuration
---------------------

	git clone https://github.com/ReturnInfinity/BareMetal-OS.git
	cd BareMetal-OS
	./setup.sh

setup.sh automatically runs build, format, and install


Rebuilding the source code
--------------------------

	./build.sh


Installing to the disk image
----------------------------

	./install.sh


Test the install with QEMU
--------------------------

	./run.sh


Test the install with Bochs
---------------------------

Bochs does not support SATA drives so this is only useful for debugging the kernel. Make sure bochs and bochs-x are installed.

	bochs -f bochs.cfg


Build a VMDK disk image for VMware
----------------------------------

	./vmdk.sh


Build a VHD disk image for VirtualMachines
------------------------------------------

        ./vhd.sh

Build a VDI disk image for VirtualBox
-------------------------------------

	./vdi.sh

The VDI script rewrites the disk ID with the contents of VDI_UUID.bin to avoid the disk warning in VirtualBox.


Build the project using GNU Make
--------------------------------

	git submodule update --init --recursive
	make

Programs in Assembly
--------------------

Automatic:

	./app.sh sysinfo.asm
	./run.sh

With GNU Make:

	make sysinfo.app

Manual:

	cd src/Examples/
	nasm sysinfo.asm -o ../../output/apps/sysinfo.app
	cd ../../output
	./bmfs --disk baremetal-os.img --offset 32KiB cp apps/sysinfo.app /Applications/sysinfo.app
	cd ..
	./run.sh

BareMetal OS should be running in the QEMU virtual machine and you should see a '>' prompt. You can now run the application by typing

	Applications/sysinfo.app


Programs in C
-------------

C programs can be compiled to take advantage of the BareMetal system calls. Standard ANSI C calls are available via Newlib (see the Newlib section below).

Automatic:

	./app.sh hello-c.c
	./run.sh

With GNU Make:

	make hello-c.app

Manual (will not work with standard C library):

	cd src/Examples
	gcc -m64 -nostdlib -nostartfiles -nodefaultlibs -fomit-frame-pointer -mno-red-zone -mcmodel=large -c program.c -o program.o
	gcc -m64 -nostdlib -nostartfiles -nodefaultlibs -fomit-frame-pointer -mno-red-zone -mcmodel=large -c libBareMetal.c -o libBareMetal.o
	ld -T example.ld libBareMetal.o program.o -o program
	objcopy -O binary program program.app
	cd ../..
	./bmfs --disk output/baremetal-os.img --offset 32KiB cp program.app /Applications/program.app
	./run.sh

BareMetal OS should be running in the QEMU virtual machine and you should see a '>' prompt. You can now run the application by typing

	Applications/program.app


Compiling Newlib
----------------

	./newlib.sh

The Newlib script will build the Newlib library and also compile a test application (test.app) to verify the build process.

The test application can also be built manually:

	cd newlib
	gcc -I newlib-2.4.0/newlib/libc/include/ -c test.c -o test.o
	ld -T app.ld -o test.app crt0.o test.o libc.a
	cp test.app ../bin
	cd ../bin
	./bmfs bmfs.image create test.app 2
	./bmfs bmfs.image write test.app
	cd ..
	./run.sh

BareMetal OS should be running in the QEMU virtual machine and you should see a '>' prompt. You can now run the application by typing

	Applications/test.app
