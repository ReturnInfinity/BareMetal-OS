# This variable tells the other makefiles
# that the libraries are being built for
# BareMetal OS.
export BAREMETAL_OS=1

# This variable controls where the libraries,
# headers, and system files are going to be generated.
OUTPUT_DIR ?= $(PWD)/output

directories += $(OUTPUT_DIR)/apps
directories += $(OUTPUT_DIR)/bin
directories += $(OUTPUT_DIR)/include
directories += $(OUTPUT_DIR)/lib
directories += $(OUTPUT_DIR)/system
directories += $(OUTPUT_DIR)/system/bootsectors

.PHONY: all
all: $(directories)
	$(MAKE) -C src/Pure64 install PREFIX="$(OUTPUT_DIR)"
	$(MAKE) -C src/kernel install PREFIX="$(OUTPUT_DIR)"
	$(MAKE) -C src/BMFS install PREFIX="$(OUTPUT_DIR)"
	$(MAKE) -C src/ironlib install PREFIX="$(OUTPUT_DIR)"
	$(MAKE) -C src/Alloy install PREFIX="$(OUTPUT_DIR)"

$(OUTPUT_DIR)/%:
	mkdir -p $@

.PHONY: clean
clean:
	$(MAKE) -C src/Pure64 clean
	$(MAKE) -C src/kernel clean
	$(MAKE) -C src/BMFS clean
	$(MAKE) -C src/ironlib clean
	$(MAKE) -C src/Alloy clean
	$(MAKE) -C src/Coreutils clean

%.app: $(OUTPUT_DIR)/apps
	$(MAKE) -C src/Coreutils $@
	cp --update src/Coreutils/$@ $(OUTPUT_DIR)/apps/$@

$(OUTPUT_DIR)/apps:
	mkdir -p $@

$(V).SILENT:
