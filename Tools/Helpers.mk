# @file Helpers.mk
# Contain helper functions used by all packages.
# @author Adrien RICCIARDI

HELPERS_PATH_ROOT = $(realpath .)
HELPERS_PATH_BUILD = $(HELPERS_PATH_ROOT)/Build
HELPERS_PATH_DOWNLOADS = $(HELPERS_PATH_ROOT)/Downloads
HELPERS_PATH_RESOURCES = $(HELPERS_PATH_ROOT)/Resources
HELPERS_PATH_TOOLS = $(HELPERS_PATH_ROOT)/Tools

# How many logical cores the build machine has
HELPERS_PROCESSORS_COUNT = $(shell cat /proc/cpuinfo | grep processor | wc -l)

# Display a visible green message.
# @param $(1) The message to display.
define HelpersDisplayMessage
	@printf "\033[32m#####################################################################\n"
	@printf "# $(1)\n"
	@printf "#####################################################################\033[0m\n"
endef

# Download an archive file and store it in the HELPERS_PATH_DOWNLOADS directory, then uncompress the archive to the build directory.
# @param $(1) The file downloading URL (including the file name).
# @param $(2) The directory name the archive file will be extracted to (this directory will be located in the HELPERS_PATH_BUILD directory.
define HelpersPrepareArchive
	$(eval Archive_File_Downloading_URL = $(1))
	$(eval Archive_File_Name = $(notdir $(1)))
	$(eval Uncompressed_Directory_Name = $(2))
	
	@# Download the file only if it is not existing in the destination directory
	if [ ! -e "$(HELPERS_PATH_DOWNLOADS)/$(Archive_File_Name)" ]; \
	then \
		wget $(Archive_File_Downloading_URL) -O "$(HELPERS_PATH_DOWNLOADS)/$(Archive_File_Name)"; \
	fi
	
	@# Uncompress the archive if it is not present in the build directory
	if [ ! -e "$(HELPERS_PATH_BUILD)/$(Uncompressed_Directory_Name)" ]; \
	then \
		mkdir -p "$(HELPERS_PATH_BUILD)/$(Uncompressed_Directory_Name)"; \
		tar -xf "$(HELPERS_PATH_DOWNLOADS)/$(Archive_File_Name)" -C "$(HELPERS_PATH_BUILD)/$(Uncompressed_Directory_Name)" --strip 1; \
	fi
endef

# Clone a git repository and store it in the HELPERS_PATH_DOWNLOADS directory.
# @param $(1) The git repository URL.
# @param $(2) The directory name the repository will be cloned to (this directory will be located in the HELPERS_PATH_BUILD directory.
define HelpersPrepareGitRepository
	$(eval Repository_URL = $(1))
	$(eval Cloned_Directory_Name = $(2))
	
	@# Clone the repository only if it is not existing in the build directory
	if [ ! -e "$(HELPERS_PATH_BUILD)/$(Cloned_Directory_Name)" ]; \
	then \
		git clone $(Repository_URL) $(HELPERS_PATH_BUILD)/$(Cloned_Directory_Name); \
	fi
endef

# Check the "package built flag".
# @param $(1) The package name (not preceded by the full path).
# @return The "ls" result on stdout if the file exists,
# @return An empty string if the file does not exist (the error is written on stderr which is redirected to /dev/null).
# @note Function is under this form to allow its result to be returned.
HelpersIsPackageBuilt = $(shell ls $(HELPERS_PATH_BUILD)/$(1)/Half_Track_Linux_Package_Built 2> /dev/null)

# Set the "package built flag".
# @param $(1) The package name (not preceded by the full path).
define HelperSetPackageBuiltFlag
	touch $(HELPERS_PATH_BUILD)/$(1)/Half_Track_Linux_Package_Built
endef