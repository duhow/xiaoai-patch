.DEFAULT_GOAL := help

BUILD_DIR = squashfs-root
FILE = mtd4
DATE := $(shell date +%y%m%d-%H%M)
MODEL ?= none
BLOCKSIZE = 131072
COMPRESSION = xz

ifeq ($(MODEL), lx01)
BLOCKSIZE := 262144
endif

ifeq ($(MODEL), lx05)
BLOCKSIZE := 262144
COMPRESSION := gzip
endif

all: extract patch build

extract:
	unsquashfs -d $(BUILD_DIR) $(FILE)

build:
ifeq ($(MODEL),none)
	$(error Please specify MODEL)
endif
	rm -f $(BUILD_DIR)/patched 2>/dev/null
	mkdir -p release
	mksquashfs $(BUILD_DIR) release/image-$(DATE) -comp $(COMPRESSION) -noappend -all-root -always-use-fragments -b $(BLOCKSIZE)
	rm -f release/latest 2>/dev/null
	ln -s image-$(DATE) release/latest

patch:
ifeq ($(MODEL),none)
	$(error Please specify MODEL)
endif
	@for PATCH in scripts/??_*.sh; do \
		echo ">> $$PATCH"; \
		ROOTFS=$(BUILD_DIR) MODEL=$(MODEL) sh $$PATCH; \
		echo "----"; \
	done | tee -a patch.log
	@touch $(BUILD_DIR)/patched

clean:
	rm -rf $(BUILD_DIR) 2>/dev/null

$(BUILD_DIR): extract
$(BUILD_DIR)/patched: patch

help:
	@echo "Usage (as root): "
	@echo ""
	@echo "  make extract FILE=mtd4 - Extract the content of the image."
	@echo "                           Beware $(BUILD_DIR) will be deleted!"
	@echo ""
	@echo "  make patch MODEL=lx01  - Apply patches."
	@echo ""
	@echo "  make build MODEL=lx01  - Create a new image in release folder."
	@echo ""
