BareMetal OS build scripts
==========================

The easiest way to create a BareMetal OS build environment. These scripts will download and compile all of the components needed for using BareMetal OS.


Prerequisites
-------------

NASM (Assembly compiler) is required to build the loader and OS, as well as the apps writen in Assembly. QEMU (computer emulator) is required if you plan on running the OS for quick testing. GCC (C compiler) is required for building the BMFS disk utility, the C applications, as well as Newlib.

In Ubuntu this can be completed with the following command:

	sudo apt-get install nasm qemu gcc


Initial configuration
---------------------

	git clone https://github.com/ReturnInfinity/BareMetal.git
	cd BareMetal
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


Build a VMDK disk image for VirtualBox
--------------------------------------

	./vmdk.sh


Compiling, installing, and running a program
--------------------------------------------

	cd src/BareMetal-OS/programs/
	nasm sysinfo.asm -o ../../../bin/sysinfo.app
	cd ../../../bin
	./bmfs bmfs.image create sysinfo.app 2
	./bmfs bmfs.image write sysinfo.app
	cd ..
	./run.sh

BareMetal OS should be running in the QEMU virtual machine and you should see a '>' prompt.

	sysinfo.app
