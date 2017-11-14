# This variable tells the other makefiles
# that the libraries are being built for
# BareMetal OS.
export BAREMETAL_OS=1

# This variable controls where the libraries,
# headers, and system files are going to be generated.
OUTPUT_DIR ?= $(PWD)/output

.PHONY: all
all:
	$(MAKE) -C src/BMFS install PREFIX="$(OUTPUT_DIR)"
	$(MAKE) -C src/ironlib install PREFIX="$(OUTPUT_DIR)"

.PHONY: clean
clean:
	$(MAKE) -C src/BMFS clean
	$(MAKE) -C src/ironlib clean
	$(MAKE) -C src/Coreutils clean

%.app: $(OUTPUT_DIR)/apps
	$(MAKE) -C src/Coreutils $@
	cp --update src/Coreutils/$@ $(OUTPUT_DIR)/apps/$@

$(OUTPUT_DIR)/apps:
	mkdir -p $@

$(V).SILENT:
