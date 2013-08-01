BareMetal OS build scripts
==========================

The easiest way to create a BareMetal OS build environment. These scripts will download and compile all of the components needed for using BareMetal OS.


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


Compiling, installing, and running an example program
-----------------------------------------------------

	cd src/BareMetal-OS/programs/
	nasm sysinfo.asm -o ../../../build/sysinfo.app
	cd ../../../build
	./bmfs bmfs.image create sysinfo.app 2
	./bmfs bmfs.image write sysinfo.app
	cd ..
	./run.sh
