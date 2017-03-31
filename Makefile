include Tools/Helpers.mk

VERSION_BUSYBOX = busybox-1.26.2
VERSION_E2FSPROGS = e2fsprogs-1.43.4
VERSION_LINUX = linux-4.10.5
VERSION_SYSLINUX = syslinux-6.03

all: prepare_build_environment system_base installer

# Include rules after the "all" rule to make "all" the default rule
include Tools/Installer.mk
include Tools/System_Base.mk

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
