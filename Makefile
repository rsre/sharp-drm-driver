obj-m += sharp-drm.o
sharp-drm-objs += src/main.o src/drm_iface.o src/params_iface.o src/ioctl_iface.o
ccflags-y := -g -std=gnu99 -Wno-declaration-after-statement

.PHONY: all clean install uninstall

# KERNELRELEASE is set by DKMS, can be different inside chroot
ifeq ($(KERNELRELEASE),)
KERNELRELEASE := $(shell uname -r)
endif
# LINUX_DIR is set by Buildroot
ifeq ($(LINUX_DIR),)
LINUX_DIR := /lib/modules/$(KERNELRELEASE)/build
endif

# BUILD_DIR is set by DKMS, but not if running manually
ifeq ($(BUILD_DIR),)
BUILD_DIR := .
endif

install_modules:
	$(MAKE) -C '$(LINUX_DIR)' M='$(shell pwd)' modules_install
	# Rebuild dependencies
	depmod -A

install: install_modules install_aux

# Separate rule to be called from DKMS
install_aux:
	# Add auto-load module line if it wasn't already there
	@grep -qxF 'sharp-drm' /etc/modules \
		|| echo 'sharp-drm' >> /etc/modules

uninstall:
	# Remove auto-load module line and create a backup file
	@sed -i.save '/sharp-drm/d' /etc/modules

clean:
	$(MAKE) -C '$(LINUX_DIR)' M='$(shell pwd)' clean
