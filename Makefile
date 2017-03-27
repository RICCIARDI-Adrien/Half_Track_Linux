include Tools/Helpers.mk

VERSION_BUSYBOX = busybox-1.26.2
VERSION_LINUX = linux-4.10.5
VERSION_SYSLINUX = syslinux-6.03

#all: linux installer
all: prepare_build_environment installer

# Include installer rules after the "all" rule to make "all" the default rule
include Tools/Installer.mk

# Set up all needed directories
prepare_build_environment:
	mkdir -p $(HELPERS_PATH_BUILD)
	mkdir -p $(HELPERS_PATH_DOWNLOADS)

# Remove all build directories
clean:
	rm -rf $(HELPERS_PATH_BUILD)/*

# Same as "clean" rule but also remove downloaded archives
distclean: clean
	rm -rf $(HELPERS_PATH_DOWNLOADS)/*

#rootfs: initramfs ?
#	mkdir $(HELPERS_PATH_BUILD)/

linux:
	$(call HelpersDisplayMessage,Compiling Linux)

	$(call HelpersPrepareFile,https://www.kernel.org/pub/linux/kernel/v4.x/$(VERSION_LINUX).tar.xz,$(VERSION_LINUX))
	@# Set custom kernel configuration
	cp $(HELPERS_PATH_RESOURCES)/$(VERSION_LINUX)_config $(HELPERS_PATH_BUILD)/$(VERSION_LINUX)/.config
	cd $(HELPERS_PATH_BUILD)/$(VERSION_LINUX) && make -j $(HELPERS_PROCESSORS_COUNT)
	# TODO get generated binary
	