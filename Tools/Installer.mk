# @file Installer.mk
# Generate an installer able to install the whole system

INSTALLER_PATH_ISO_IMAGE = $(HELPERS_PATH_BUILD)/Installer_ISO_Image
INSTALLER_PATH_ROOTFS = $(HELPERS_PATH_BUILD)/Installer_Rootfs

# This makefile entry point
installer: installer_prepare_rootfs installer_prepare_iso_image installer_syslinux installer_linux installer_create_iso_image

# Populate a minimal rootfs just enough to allow following package binaries to be copied on it
installer_prepare_rootfs:
	mkdir -p $(INSTALLER_PATH_ROOTFS)/bin
	mkdir -p $(INSTALLER_PATH_ROOTFS)/dev
	mkdir -p $(INSTALLER_PATH_ROOTFS)/proc
	mkdir -p $(INSTALLER_PATH_ROOTFS)/usr/bin
	mkdir -p $(INSTALLER_PATH_ROOTFS)/sys
	
	@# Populate rootfs with static files
	#cp -r $(HELPERS_PATH_RESOURCES)/Installer_Rootfs/* $(INSTALLER_PATH_ROOTFS)

installer_prepare_iso_image:
	mkdir -p $(INSTALLER_PATH_ISO_IMAGE)

installer_syslinux:
	$(call HelpersDisplayMessage,[Installer] SYSLINUX (ISOLINUX CDROM bootloader))
	$(call HelpersPrepareFile,https://www.kernel.org/pub/linux/utils/boot/syslinux/$(VERSION_SYSLINUX).tar.xz,Installer_Syslinux)
	
	@# No need to compile, the isolinux binary is present in the archive, so copy it to the rootfs (refer to http://www.syslinux.org/wiki/index.php?title=ISOLINUX to know what files to copy)
	mkdir -p $(INSTALLER_PATH_ISO_IMAGE)/isolinux
	cp $(HELPERS_PATH_BUILD)/Installer_Syslinux/bios/core/isolinux.bin $(INSTALLER_PATH_ISO_IMAGE)/isolinux
	cp $(HELPERS_PATH_BUILD)/Installer_Syslinux/bios/com32/elflink/ldlinux/ldlinux.c32 $(INSTALLER_PATH_ISO_IMAGE)/isolinux
	cp $(HELPERS_PATH_RESOURCES)/Installer_isolinux.cfg $(INSTALLER_PATH_ISO_IMAGE)/isolinux/isolinux.cfg

installer_linux:
	$(call HelpersDisplayMessage,[Installer] Linux (kernel))
	$(call HelpersPrepareFile,https://www.kernel.org/pub/linux/kernel/v4.x/$(VERSION_LINUX).tar.xz,Installer_Linux)
	
	@# Set custom kernel configuration
	cp $(HELPERS_PATH_RESOURCES)/Installer_$(VERSION_LINUX)_config $(HELPERS_PATH_BUILD)/Installer_Linux/.config
	@# Build the kernel
	cd $(HELPERS_PATH_BUILD)/Installer_Linux && make -j $(HELPERS_PROCESSORS_COUNT)
	@# Copy kernel image to ISO image
	cp $(HELPERS_PATH_BUILD)/Installer_Linux/arch/x86/boot/bzImage $(INSTALLER_PATH_ISO_IMAGE)/vmlinux

installer_create_iso_image:
	$(call HelpersDisplayMessage,[Installer] Create CDROM ISO image)
	mkisofs -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o Half_Track_Linux.iso $(INSTALLER_PATH_ISO_IMAGE)