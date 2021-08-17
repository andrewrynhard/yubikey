.PHONY: all clean

EXECUTABLES = packer ansible qemu-system-x86_64
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH)))

SHELL=/bin/bash

export VERSION := $(shell date -u +%Y%m%d%H%M)
export CHECKPOINT_DISABLE := 1
export PACKER_LOG := 1
export PACKER_CACHE_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))/.packer/cache

DISK ?= /dev/null

all: clean
	packer build --parallel-builds=1 packer/build.json

write:
	gunzip -f dist/airgap-latest.raw.gz >dist/airgap-latest.raw
	sudo dd if=dist/airgap-latest.raw of=$(DISK) status=progress

clean:
	rm -rf dist
	rm -rf .packer/build

