# @file Installer.mk
# Generate an installer able to install the whole system

INSTALLER_PATH_ISO_IMAGE = $(HELPERS_PATH_BUILD)/Installer_ISO_Image
INSTALLER_PATH_ROOTFS = $(HELPERS_PATH_BUILD)/Installer_Rootfs

# This makefile entry point
installer: installer_prepare_rootfs installer_busybox installer_prepare_iso_image installer_syslinux installer_linux installer_create_iso_image

# Populate a minimal rootfs just enough to allow following package binaries to be copied on it
installer_prepare_rootfs:
	mkdir -p $(INSTALLER_PATH_ROOTFS)/bin
	mkdir -p $(INSTALLER_PATH_ROOTFS)/dev
	mkdir -p $(INSTALLER_PATH_ROOTFS)/proc
	mkdir -p $(INSTALLER_PATH_ROOTFS)/usr/bin
	mkdir -p $(INSTALLER_PATH_ROOTFS)/sys
	
	@# Create useful device nodes
	if [ ! -e $(INSTALLER_PATH_ROOTFS)/dev/console ]; then sudo mknod -m 600 $(INSTALLER_PATH_ROOTFS)/dev/console c 5 1; fi
	if [ ! -e $(INSTALLER_PATH_ROOTFS)/dev/null ]; then sudo mknod -m 666 $(INSTALLER_PATH_ROOTFS)/dev/null c 1 3; fi
	if [ ! -e $(INSTALLER_PATH_ROOTFS)/dev/random ]; then sudo mknod -m 666 $(INSTALLER_PATH_ROOTFS)/dev/random c 1 8; fi
	if [ ! -e $(INSTALLER_PATH_ROOTFS)/dev/tty ]; then sudo mknod -m 666 $(INSTALLER_PATH_ROOTFS)/dev/tty c 5 0; fi
	if [ ! -e $(INSTALLER_PATH_ROOTFS)/dev/tty0 ]; then sudo mknod $(INSTALLER_PATH_ROOTFS)/dev/tty0 c 4 0; fi
	if [ ! -e $(INSTALLER_PATH_ROOTFS)/dev/tty1 ]; then sudo mknod $(INSTALLER_PATH_ROOTFS)/dev/tty1 c 4 1; fi
	if [ ! -e $(INSTALLER_PATH_ROOTFS)/dev/tty2 ]; then sudo mknod $(INSTALLER_PATH_ROOTFS)/dev/tty2 c 4 2; fi
	if [ ! -e $(INSTALLER_PATH_ROOTFS)/dev/tty3 ]; then sudo mknod $(INSTALLER_PATH_ROOTFS)/dev/tty3 c 4 3; fi
	if [ ! -e $(INSTALLER_PATH_ROOTFS)/dev/tty4 ]; then sudo mknod $(INSTALLER_PATH_ROOTFS)/dev/tty4 c 4 4; fi
	if [ ! -e $(INSTALLER_PATH_ROOTFS)/dev/tty5 ]; then sudo mknod $(INSTALLER_PATH_ROOTFS)/dev/tty5 c 4 5; fi
	if [ ! -e $(INSTALLER_PATH_ROOTFS)/dev/tty6 ]; then sudo mknod $(INSTALLER_PATH_ROOTFS)/dev/tty6 c 4 6; fi
	if [ ! -e $(INSTALLER_PATH_ROOTFS)/dev/tty7 ]; then sudo mknod $(INSTALLER_PATH_ROOTFS)/dev/tty7 c 4 7; fi
	if [ ! -e $(INSTALLER_PATH_ROOTFS)/dev/urandom ]; then sudo mknod -m 666 $(INSTALLER_PATH_ROOTFS)/dev/urandom c 1 9; fi
	if [ ! -e $(INSTALLER_PATH_ROOTFS)/dev/zero ]; then sudo mknod -m 666 $(INSTALLER_PATH_ROOTFS)/dev/zero c 1 5; fi
	
	@# Populate rootfs with static files
	#cp -r $(HELPERS_PATH_RESOURCES)/Installer_Rootfs/* $(INSTALLER_PATH_ROOTFS)

installer_busybox:
	$(call HelpersDisplayMessage,[Installer] Busybox (base system and utilities))
	$(call HelpersPrepareFile,https://www.busybox.net/downloads/$(VERSION_BUSYBOX).tar.bz2,Installer_Busybox)
	
	cp $(HELPERS_PATH_RESOURCES)/Installer_$(VERSION_BUSYBOX)_config $(HELPERS_PATH_BUILD)/Installer_Busybox/.config
	cd $(HELPERS_PATH_BUILD)/Installer_Busybox && make -j $(HELPERS_PROCESSORS_COUNT) && make install

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