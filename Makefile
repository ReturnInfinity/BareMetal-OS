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

C_INCLUDE_PATH=$(PREFIX)/include

export C_INCLUDE_PATH

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

fs_offset = 32KiB

.PHONY: all
all: $(directories) $(PREFIX)/baremetal-os.img

$(PREFIX)/baremetal-os.img: $(PREFIX)/bin/bmfs $(systemfiles)
	$(PREFIX)/bin/bmfs --disk $@ --offset $(fs_offset) format -f
	$(PREFIX)/bin/bmfs --disk $@ --offset $(fs_offset) mkdir /System /Applications /Home
	$(PREFIX)/bin/bmfs --disk $@ --offset $(fs_offset) cp $(PREFIX)/system/alloy.bin /System/alloy.bin

$(PREFIX)/bin/bmfs $(PREFIX)/lib/libbmfs.a:
	$(MAKE) -C src/BMFS install

$(systemfiles):
	$(MAKE) -C src/Pure64 install
	$(MAKE) -C src/kernel install
	$(MAKE) -C src/Alloy CONFIG=baremetal install

$(directories):
	mkdir -p $@

.PHONY: clean
clean:
	$(MAKE) -C src/Pure64 clean
	$(MAKE) -C src/kernel clean
	$(MAKE) -C src/BMFS clean
	$(MAKE) -C src/Alloy CONFIG=baremetal clean
	$(MAKE) -C src/Examples clean

%.app: $(PREFIX)/apps
	$(MAKE) -C src/Examples $@
	cp --update src/Examples/$@ $(PREFIX)/apps/$@
	$(PREFIX)/bin/bmfs --disk $(PREFIX)/baremetal-os.img --offset $(fs_offset) rm -f $@
	$(PREFIX)/bin/bmfs --disk $(PREFIX)/baremetal-os.img --offset $(fs_offset) cp $< /Applications/$@

$(V).SILENT:
