BareMetal OS build scripts
==========================

The easiest way to create a BareMetal OS build environment. These scripts will download and compile all of the components needed for using BareMetal OS.


Prerequisites
-------------

NASM (Assembly compiler) is required to build the loader and OS, as well as the apps writen in Assembly. QEMU (computer emulator) is required if you plan on running the OS for quick testing. GCC (C compiler) is required for building the BMFS disk utility, the C applications, as well as Newlib. Git is used for pulling the software from GitHub. Automake is used to build the BMFS disk utility.

In Ubuntu this can be completed with the following command:

	sudo apt-get install nasm qemu gcc git automake

There are additional dependencies if you are planning on compiling Newlib. They can be installed with the following command:

	sudo apt-get install autoconf libtool sed gawk bison flex m4 texinfo texi2html unzip make


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


Build a VMDK disk image for VMware
----------------------------------

	./vmdk.sh


Build a VDI disk image for VirtualBox
-------------------------------------

	./vdi.sh

The VDI script rewrites the disk ID with the contents of VDI_UUID.bin to avoid the disk warning in VirtualBox.


Compiling, installing, and running a program in Assembly
--------------------------------------------

Automatic:

	./app.sh sysinfo
	./run.sh

Manual:

	nasm sysinfo.asm -o bin/sysinfo.app
	cd bin
	./bmfs bmfs.image create sysinfo.app 2
	./bmfs bmfs.image write sysinfo.app
	cd ..
	./run.sh


BareMetal OS should be running in the QEMU virtual machine and you should see a '>' prompt. You can now run the application by typing

	sysinfo.app


Compiling Newlib
----------------

	./newlib.sh

The Newlib script will build the Newlib library and also compile a test application (test.app) to verify the build process.


Compiling, installing, and running a program in C with Newlib
--------------------------------------------

Once you have compilied newlib, you can now compile and run C programs.
Automatic:

	./appc.sh sysinfo
	./run.sh

Manual:


	gcc -c -m64 -nostdlib -nostartfiles -nodefaultlibs -fomit-frame-pointer -mno-red-zone -o test.o test.c
	gcc -c -m64 -nostdlib -nostartfiles -nodefaultlibs -fomit-frame-pointer -mno-red-zone -o libBareMetal.o libBareMetal.c
	ld -T app.ld -o bin/test.app test.o libBareMetal.o
	cd bin
	./bmfs bmfs.image create test.app 2
	./bmfs bmfs.image write test.app
	cd ..
	./run.sh


BareMetal OS should be running in the QEMU virtual machine and you should see a '>' prompt.

	test.app

