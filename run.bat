cd "bin"

qemu-system-x86_64 ^
	-machine q35 ^
	-cpu core2duo ^
	-name "BareMetal OS" ^
	-device e1000,netdev=net0 ^
	-netdev user,id=net0 ^
	-smp 2 ^
	-m 256 ^
	-drive id=disk,file="bmfs.image",if=none,format=raw ^
	-device ahci,id=ahci ^
	-device ide-drive,drive=disk,bus=ahci.0

cd ".."
