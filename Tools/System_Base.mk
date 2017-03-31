# @file System_Base.mk
# Generate system base packages (kernel, C library, busybox utilities...).

SYSTEM_BASE_PATH_ROOTFS = $(HELPERS_PATH_BUILD)/System_Rootfs

system_base: system_base_prepare_rootfs system_base_linux system_base_create_rootfs

# Populate a minimal rootfs just enough to allow following package binaries to be copied on it
system_base_prepare_rootfs:
	mkdir -p $(SYSTEM_BASE_PATH_ROOTFS)/bin
	mkdir -p $(SYSTEM_BASE_PATH_ROOTFS)/boot
	mkdir -p $(SYSTEM_BASE_PATH_ROOTFS)/dev
	mkdir -p $(SYSTEM_BASE_PATH_ROOTFS)/mnt
	mkdir -p $(SYSTEM_BASE_PATH_ROOTFS)/proc
	mkdir -p $(SYSTEM_BASE_PATH_ROOTFS)/usr/bin
	mkdir -p $(SYSTEM_BASE_PATH_ROOTFS)/sys
	
	@# Create useful device nodes
	if [ ! -e $(SYSTEM_BASE_PATH_ROOTFS)/dev/console ]; then sudo mknod -m 600 $(SYSTEM_BASE_PATH_ROOTFS)/dev/console c 5 1; fi
	if [ ! -e $(SYSTEM_BASE_PATH_ROOTFS)/dev/null ]; then sudo mknod -m 666 $(SYSTEM_BASE_PATH_ROOTFS)/dev/null c 1 3; fi
	if [ ! -e $(SYSTEM_BASE_PATH_ROOTFS)/dev/random ]; then sudo mknod -m 666 $(SYSTEM_BASE_PATH_ROOTFS)/dev/random c 1 8; fi
	if [ ! -e $(SYSTEM_BASE_PATH_ROOTFS)/dev/tty ]; then sudo mknod -m 666 $(SYSTEM_BASE_PATH_ROOTFS)/dev/tty c 5 0; fi
	if [ ! -e $(SYSTEM_BASE_PATH_ROOTFS)/dev/tty0 ]; then sudo mknod $(SYSTEM_BASE_PATH_ROOTFS)/dev/tty0 c 4 0; fi
	if [ ! -e $(SYSTEM_BASE_PATH_ROOTFS)/dev/tty1 ]; then sudo mknod $(SYSTEM_BASE_PATH_ROOTFS)/dev/tty1 c 4 1; fi
	if [ ! -e $(SYSTEM_BASE_PATH_ROOTFS)/dev/tty2 ]; then sudo mknod $(SYSTEM_BASE_PATH_ROOTFS)/dev/tty2 c 4 2; fi
	if [ ! -e $(SYSTEM_BASE_PATH_ROOTFS)/dev/tty3 ]; then sudo mknod $(SYSTEM_BASE_PATH_ROOTFS)/dev/tty3 c 4 3; fi
	if [ ! -e $(SYSTEM_BASE_PATH_ROOTFS)/dev/tty4 ]; then sudo mknod $(SYSTEM_BASE_PATH_ROOTFS)/dev/tty4 c 4 4; fi
	if [ ! -e $(SYSTEM_BASE_PATH_ROOTFS)/dev/tty5 ]; then sudo mknod $(SYSTEM_BASE_PATH_ROOTFS)/dev/tty5 c 4 5; fi
	if [ ! -e $(SYSTEM_BASE_PATH_ROOTFS)/dev/tty6 ]; then sudo mknod $(SYSTEM_BASE_PATH_ROOTFS)/dev/tty6 c 4 6; fi
	if [ ! -e $(SYSTEM_BASE_PATH_ROOTFS)/dev/tty7 ]; then sudo mknod $(SYSTEM_BASE_PATH_ROOTFS)/dev/tty7 c 4 7; fi
	if [ ! -e $(SYSTEM_BASE_PATH_ROOTFS)/dev/urandom ]; then sudo mknod -m 666 $(SYSTEM_BASE_PATH_ROOTFS)/dev/urandom c 1 9; fi
	if [ ! -e $(SYSTEM_BASE_PATH_ROOTFS)/dev/zero ]; then sudo mknod -m 666 $(SYSTEM_BASE_PATH_ROOTFS)/dev/zero c 1 5; fi
	
	@# Populate rootfs with static files
	#cp -r $(HELPERS_PATH_RESOURCES)/System_Rootfs/* $(SYSTEM_BASE_PATH_ROOTFS)

system_base_linux:
	$(call HelpersDisplayMessage,[System] Linux (kernel))
	$(call HelpersPrepareArchive,https://www.kernel.org/pub/linux/kernel/v4.x/$(VERSION_LINUX).tar.xz,System_Linux)
	
	$(if $(call HelpersIsPackageBuilt,System_Linux),, \
		cp $(HELPERS_PATH_RESOURCES)/System_$(VERSION_LINUX)_config $(HELPERS_PATH_BUILD)/System_Linux/.config; \
		cd $(HELPERS_PATH_BUILD)/System_Linux && make -j $(HELPERS_PROCESSORS_COUNT) \
	)
	$(call HelperSetPackageBuiltFlag,System_Linux)
	
	@# Copy kernel image to rootfs
	cp $(HELPERS_PATH_BUILD)/System_Linux/arch/x86/boot/bzImage $(SYSTEM_BASE_PATH_ROOTFS)/boot/vmlinux
	@# Install modules to rootfs
	cd $(HELPERS_PATH_BUILD)/System_Linux && INSTALL_MOD_PATH=$(SYSTEM_BASE_PATH_ROOTFS) make modules_install

# Compress the rootfs to an archive that will be embedded on the installer ISO image
system_base_create_rootfs:
	$(call HelpersDisplayMessage,[System] Compressing rootfs)
	cd $(HELPERS_PATH_BUILD) && tar -jc System_Rootfs -f $(HELPERS_PATH_BUILD)/System_Rootfs.tar.bz2