# @file Installer.mk
# Generate an installer able to install the whole system

INSTALLER_PATH_ROOTFS = $(HELPERS_PATH_BUILD)/Installer_Rootfs

# This makefile entry point
installer: installer_rootfs_create_directories installer_syslinux installer_linux

# Populate a minimal rootfs just enough to allow following package binaries to be copied on it
installer_rootfs_create_directories:
	mkdir -p $(INSTALLER_PATH_ROOTFS)/bin
	mkdir -p $(INSTALLER_PATH_ROOTFS)/dev
	mkdir -p $(INSTALLER_PATH_ROOTFS)/proc
	mkdir -p $(INSTALLER_PATH_ROOTFS)/usr/bin
	mkdir -p $(INSTALLER_PATH_ROOTFS)/sys

installer_syslinux:
	$(call HelpersDisplayMessage,[Installer] SYSLINUX (ISOLINUX CDROM bootloader))
	$(call HelpersPrepareFile,https://www.kernel.org/pub/linux/utils/boot/syslinux/$(VERSION_SYSLINUX).tar.xz,Installer_Syslinux)
	
	@# No need to compile, the isolinux binary is present in the archive, so copy it to the rootfs (refer to http://www.syslinux.org/wiki/index.php?title=ISOLINUX to know what files to copy)
	mkdir -p $(INSTALLER_PATH_ROOTFS)/isolinux
	cp $(HELPERS_PATH_BUILD)/Installer_Syslinux/bios/core/isolinux.bin $(INSTALLER_PATH_ROOTFS)/isolinux
	cp $(HELPERS_PATH_BUILD)/Installer_Syslinux/bios/com32/elflink/ldlinux/ldlinux.c32 $(INSTALLER_PATH_ROOTFS)/isolinux
	cp $(HELPERS_PATH_RESOURCES)/Installer_isolinux.cfg $(INSTALLER_PATH_ROOTFS)/isolinux/isolinux.cfg

installer_linux:
	$(call HelpersDisplayMessage,[Installer] Linux (kernel))
	$(call HelpersPrepareFile,https://www.kernel.org/pub/linux/kernel/v4.x/$(VERSION_LINUX).tar.xz,Installer_Linux)
	
	@# Set custom kernel configuration
	cp $(HELPERS_PATH_RESOURCES)/Installer_$(VERSION_LINUX)_config $(HELPERS_PATH_BUILD)/Installer_Linux/.config
	@# Build the kernel
	cd $(HELPERS_PATH_BUILD)/Installer_Linux && make -j $(HELPERS_PROCESSORS_COUNT)

