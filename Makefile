# This variable tells the other makefiles
# that the libraries are being built for
# BareMetal OS.
export BAREMETAL_OS=1

# This variable controls where the libraries,
# headers, and system files are going to be generated.
ifndef PREFIX
PREFIX := $(PWD)/output
endif
export PREFIX

directories += $(PREFIX)/apps
directories += $(PREFIX)/bin
directories += $(PREFIX)/include
directories += $(PREFIX)/lib
directories += $(PREFIX)/system
directories += $(PREFIX)/system/bootsectors

systemfiles += $(PREFIX)/system/bootsectors/bmfs_mbr.sys
systemfiles += $(PREFIX)/system/pure64.sys
systemfiles += $(PREFIX)/system/kernel.sys
systemfiles += $(PREFIX)/system/loader.bin
systemfiles += $(PREFIX)/system/alloy.bin

.PHONY: all
all: $(directories) $(PREFIX)/baremetal-os.img

$(PREFIX)/baremetal-os.img: $(PREFIX)/bin/bmfs $(systemfiles)
	$(PREFIX)/bin/bmfs $@ initialize 128M $(PREFIX)/system/bootsectors/bmfs_mbr.sys $(PREFIX)/system/pure64.sys $(PREFIX)/system/kernel.sys $(PREFIX)/system/loader.bin
	$(PREFIX)/bin/bmfs $@ mkdir programs
	$(PREFIX)/bin/bmfs $@ create alloy.bin 2M
	$(PREFIX)/bin/bmfs $@ write alloy.bin $(PREFIX)/system/alloy.bin

$(PREFIX)/bin/bmfs $(PREFIX)/lib/libbmfs.a:
	$(MAKE) -C src/BMFS install

$(systemfiles):
	$(MAKE) -C src/Pure64 install
	$(MAKE) -C src/kernel install
	$(MAKE) -C src/ironlib install
	$(MAKE) -C src/Alloy install

$(directories):
	mkdir -p $@

.PHONY: clean
clean:
	$(MAKE) -C src/Pure64 clean
	$(MAKE) -C src/kernel clean
	$(MAKE) -C src/BMFS clean
	$(MAKE) -C src/ironlib clean
	$(MAKE) -C src/Alloy clean
	$(MAKE) -C src/Coreutils clean

%.app: $(PREFIX)/apps
	$(MAKE) -C src/Coreutils $@
	cp --update src/Coreutils/$@ $(PREFIX)/apps/$@
	$(PREFIX)/bin/bmfs $(PREFIX)/baremetal-os.img delete $@
	$(PREFIX)/bin/bmfs $(PREFIX)/baremetal-os.img create $@ 2M
	$(PREFIX)/bin/bmfs $(PREFIX)/baremetal-os.img write $@ src/Coreutils/$@

$(V).SILENT:
