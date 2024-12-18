.DEFAULT_GOAL := help

OCI_REPO = ghcr.io/duhow/xiaoai-patch
OCI_DIR = docker_pull

BUILD_DIR = squashfs-root
FILE = mtd4
LINUX ?= none
DATETIME := $(shell date +%y%m%d-%H%M)
DATE := $(shell date +%y%m%d)
MODEL ?= none
override MODEL := $(shell echo $(MODEL) | tr '[:upper:]' '[:lower:]')
IMAGE_NAME = image-$(DATETIME)
DESTDIR ?= release/$(MODEL)
RELEASE_DIR = $(DESTDIR)/release_$(DATETIME)
RELEASE_FILE = $(DESTDIR)/mico_firmware.tar
BLOCKSIZE = 131072
COMPRESSION = xz

ifeq ($(MODEL), lx01)
BLOCKSIZE := 262144
IMAGE_MAX_SIZE := 30408704
endif

ifeq ($(MODEL), lx05)
BLOCKSIZE := 262144
COMPRESSION := gzip
endif

ifeq ($(MODEL), lx06)
IMAGE_MAX_SIZE := 41943040
endif

ifeq ($(MODEL), l09a)
IMAGE_MAX_SIZE := 41943040
endif

# only for CHROME partition, SYSTEM uses xz
ifeq ($(MODEL), l09g)
COMPRESSION := gzip
IMAGE_MAX_SIZE := 71303168
# system: IMAGE_MAX_SIZE := 16777216
endif

ifeq ($(MODEL), s12)
BUILD_DIR := /mnt/ubi.tmp
endif

ifeq ($(MODEL), s12a)
COMPRESSION := gzip
endif

.PHONY: all clean clean-packages pull extract patch build release help

all: extract patch build release

ifeq ($(MODEL), s12)
extract: extract_ubifs
build: prebuild build_ubifs postbuild
else
extract: extract_squashfs
build: prebuild build_squashfs postbuild
endif

modprobe_mtd:
	modprobe nandsim first_id_byte=0xec second_id_byte=0xa1 third_id_byte=0x00 fourth_id_byte=0x15
	modprobe ubi mtd=0

extract_squashfs:
	unsquashfs -d $(BUILD_DIR) $(FILE)

extract_ubifs: modprobe_mtd
	-umount -q $(BUILD_DIR)
	ubidetach /dev/ubi_ctrl -m 0
	ubiformat /dev/mtd0 -f $(FILE) -s 2048 -O 2048 -y
	ubiattach /dev/ubi_ctrl -m 0 -O 2048
	mkdir -p $(BUILD_DIR)
	mount -t ubifs ubi0 $(BUILD_DIR)

prebuild:
ifeq ($(MODEL),none)
	$(error Please specify MODEL)
endif
	rm -f $(BUILD_DIR)/patched 2>/dev/null
	mkdir -p $(DESTDIR)

postbuild:
	rm -f $(DESTDIR)/latest 2>/dev/null
	ln -sf $(IMAGE_NAME) $(DESTDIR)/latest

get_version:
MICO_VERSION = $(BUILD_DIR)/usr/share/mico/version
ROOTFS_VERSION = $(shell grep 'option ROOTFS' $(MICO_VERSION) | awk '{print $$3}' | tr -d "'")
ROM_VERSION = $(shell grep 'option ROM' $(MICO_VERSION) | awk '{print $$3}' | tr -d "'")

release_set_config:
	mkdir -p $(RELEASE_DIR)
	cp -f $(MICO_VERSION) $(RELEASE_DIR)/metadata
	@IMAGE_MD5=$(shell md5sum $(DESTDIR)/$(IMAGE_NAME) | cut -d ' ' -f 1); \
	echo "config core 'hash'" >> $(RELEASE_DIR)/metadata; \
	echo -e "\toption ROOTFS '$$IMAGE_MD5'" >> $(RELEASE_DIR)/metadata
ifeq ($(LINUX),none)
	@true
else
	@LINUX_MD5=$(shell md5sum $(LINUX) | cut -d ' ' -f 1); \
	echo -e "\toption LINUX '$$LINUX_MD5'" >> $(RELEASE_DIR)/metadata
endif

release_pack:
	@cp $(DESTDIR)/$(IMAGE_NAME) $(RELEASE_DIR)/root.squashfs
ifeq ($(LINUX),none)
	@true
else
	@cp $(LINUX) $(RELEASE_DIR)/boot.img
endif
	tar -cf $(RELEASE_FILE) -C $(RELEASE_DIR) .

release: get_version release_set_config release_pack
	MD5TAR=$(shell md5sum $(RELEASE_FILE) | cut -d ' ' -f 1); \
	mv $(RELEASE_FILE) $(DESTDIR)/mico_firmware_$${MD5TAR: -7}_$(DATE)_$(MODEL).tar
	rm -rf $(RELEASE_DIR)

build_squashfs:
	mksquashfs $(BUILD_DIR) $(DESTDIR)/$(IMAGE_NAME) -comp $(COMPRESSION) -noappend -all-root -always-use-fragments -b $(BLOCKSIZE)
	@[ -n "$(IMAGE_MAX_SIZE)" ] && \
	[ "`stat -L -c %s $(DESTDIR)/$(IMAGE_NAME)`" -ge "$(IMAGE_MAX_SIZE)" ] && \
	  echo "!!! WARNING: Image built is larger than allowed! - $(IMAGE_MAX_SIZE)" && exit 1 \
	|| true

build_ubifs: make_ubifs ubi.ini
	ubinize -o $(DESTDIR)/$(IMAGE_NAME) -p 131072 -m 2048 -s 2048 -O 2048 ubi.ini
	@rm -vf ubi.ini ubifs.img 2>/dev/null

make_ubifs:
	@rm -vf ubi.ini ubifs.img 2>/dev/null
	mkfs.ubifs -m 2048 -e 126976 -c 1024 -r $(BUILD_DIR) ubifs.img -x none

ubi.ini: ubifs.img
	echo "[ubi_rfs]\nmode=ubi\nimage=$<\nvol_id=0\nvol_size=`stat -c %s $<`\nvol_type=dynamic\nvol_name=rootfs\nvol_alignment=1\nvol_flags=autoresize" > $@

patch:
ifeq ($(MODEL),none)
	$(error Please specify MODEL)
endif
	@for PATCH in scripts/??_*.sh; do \
		echo ">> $$PATCH"; \
		ROOTFS=$(BUILD_DIR) MODEL=$(MODEL) sh $$PATCH 2>&1; \
		EXITCODE=$$? ; \
		if [ $$EXITCODE -ne 0 ]; then \
			echo "!!! ERROR: $$PATCH failed with exit code $$EXITCODE"; \
			kill $$PPID ; \
		fi; \
		echo "----"; \
	done | tee -a patch.log
	@touch $(BUILD_DIR)/patched

clean:
ifeq ($(MODEL), s12)
	-umount -q $(BUILD_DIR)
	-rmmod ubifs ubi nandsim
endif
	rm -rf $(BUILD_DIR) 2>/dev/null

clean-packages:
	rm -rf build-packages/s2t
	rm -rf build-packages/staging
	rm -rf build-packages/build

pull:
ifeq ($(MODEL),none)
	$(error Please specify MODEL)
endif
	@if [ -n "$(wildcard $(BUILD_DIR)/*)" ]; then echo "$(BUILD_DIR) is not empty, clean before pulling"; exit 1; fi
	@mkdir -p $(OCI_DIR) $(BUILD_DIR)
	docker inspect $(OCI_REPO)/$(MODEL):base >/dev/null || docker pull $(OCI_REPO)/$(MODEL):base
	docker image save $(OCI_REPO)/$(MODEL):base | tar x -C $(OCI_DIR)
	@IMAGE=`jq -r '.[0].Layers[0]' $(OCI_DIR)/manifest.json`; \
	  tar xf $(OCI_DIR)/$$IMAGE -C $(BUILD_DIR)
	@rm -rf $(OCI_DIR)

$(BUILD_DIR): extract
$(BUILD_DIR)/patched: patch
/dev/mtd0: modprobe_mtd

help:
	@echo "Usage (as root): "
	@echo ""
	@echo "  make extract FILE=mtd4   - Extract the content of the image."
	@echo "                             Beware $(BUILD_DIR) will be deleted!"
	@echo ""
	@echo "  make patch MODEL=lx01    - Apply patches."
	@echo ""
	@echo "  make build MODEL=lx01    - Create a new image in release folder."
	@echo ""
	@echo "  make release MODEL=lx01  - Creates a packed release image in release folder."
	@echo ""