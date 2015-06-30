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


Programs in Assembly
--------------------

Automatic:

	./app.sh sysinfo
	./run.sh

Manual:

	cd src/BareMetal-OS/programs/
	nasm sysinfo.asm -o ../../../bin/sysinfo.app
	cd ../../../bin
	./bmfs bmfs.image create sysinfo.app 2
	./bmfs bmfs.image write sysinfo.app
	cd ..
	./run.sh


BareMetal OS should be running in the QEMU virtual machine and you should see a '>' prompt. You can now run the application by typing

	sysinfo.app


Programs in C
-------------

C programs can be compiled to take advantage of the BareMetal system calls. Standard ANSI C calls are available via Newlib (see the Newlib section below).

Automatic:

	./appc.sh helloc
	./run.sh

Manual:

	cd src/
	gcc -c -m64 -nostdlib -nostartfiles -nodefaultlibs -fomit-frame-pointer -mno-red-zone -o hello.o helloc.c
	gcc -c -m64 -nostdlib -nostartfiles -nodefaultlibs -fomit-frame-pointer -mno-red-zone -o libBareMetal.o libBareMetal.c
	ld -T app.ld -o bin/helloc.app helloc.o libBareMetal.o
	cd bin
	./bmfs bmfs.image create helloc.app 2
	./bmfs bmfs.image write helloc.app
	cd ..
	./run.sh

BareMetal OS should be running in the QEMU virtual machine and you should see a '>' prompt. You can now run the application by typing

	helloc.app


Compiling Newlib
----------------

	./newlib.sh

The Newlib script will build the Newlib library and also compile a test application (test.app) to verify the build process.

The test application can also be built manually:

	cd newlib
	gcc -I newlib-2.2.0/newlib/libc/include/ -c test.c -o test.o
	ld -T app.ld -o test.app crt0.o test.o libc.a
	cp test.app ../bin
    cd ../bin
	./bmfs bmfs.image create test.app 2
	./bmfs bmfs.image write test.app
	cd ..
	./run.sh

BareMetal OS should be running in the QEMU virtual machine and you should see a '>' prompt. You can now run the application by typing

	test.app
