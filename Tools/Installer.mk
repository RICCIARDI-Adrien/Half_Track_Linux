# @file Installer.mk
# Generate an installer able to install the whole system

# This makefile entry point
installer: installer_linux

installer_linux:
	$(call HelpersDisplayMessage,[Installer] Compiling Linux)

	$(call HelpersPrepareFile,https://www.kernel.org/pub/linux/kernel/v4.x/$(VERSION_LINUX).tar.xz,Installer_Linux)
	@# Set custom kernel configuration
	cp $(HELPERS_PATH_RESOURCES)/Installer_$(VERSION_LINUX)_config $(HELPERS_PATH_BUILD)/Installer_Linux/.config
	cd $(HELPERS_PATH_BUILD)/Installer_Linux && make -j $(HELPERS_PROCESSORS_COUNT)

