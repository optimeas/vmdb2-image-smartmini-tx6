# Vmdb2-image-smartmini-tx6

This repository contains scripts and files to generate a MfgTool archive which can
be used to flash a minimal Debian bullseye on a smartmini type device. Additonally
this repository also holds information for the installation, usage and configuration
of the a Debian system on the devices.

This page functions as a getting started guide. For further instructions
for sepcific configuration and use issues of hardware and software components, refer
to the pages inside the `doc` subdirectory.

## Quick-start with a fresh Debian smartDevice

After starting up your device, connect the device via ethernet directly to your host. The standard
configuration for the devices for the ip address is:

    10.20.30.40/24

Inital credentials of the image:

General user account:
	
	username: user
	password: user

Credentials for superuser:
	
	password: toor

You will need to configure your hosts ethernet interface, that is connected to your smartDevice. The should be configured with an address in the same subnet of the above mentioned address, in order to communicate with the device.

### Toolchain for C/C++ Development

TBD...

## Building a vmdb2 image plus MFGTool

To build a MFGTool archive which you can use in order to reset your device to factory settings, you can 
use this repository to generate your own MfgTool.

You may skip this section for the time if you only whish to work and develop on your Debian smartDevice.

### Supported target devices

At the moment the images will be built for the following platforms:

* smartRAIL v1/v2
* smartMINI v2

### Required packages for building the image (incl. the kernel)

These packages need to be installed and updated on your debian bullseye host in order to be able to use the
tools in this repository:

    sudo apt install bison flex bc lzop gcc-arm-linux-gnueabihf vmdb2 dosfstools \
    qemu-user-static binfmt-support time kpartx bmap-tools u-boot-tools

### Generating MfgTools

To generate a MfgTool archive for a smartRAIL aswell for an smartMINI execute the script:

    ./buildall.py

The generated compressed archives of the MfgTool can be found under `output/build-<recent timestamp>/mfg/`.

Refer to `doc/flashSmartDevice.md` if you require a step-by-step description for the flash process with the
MfgTool.

### Flashing the image to a SD-card

    lsblk

=> Find device file of YOUR sd-card device ...

    sudo bmaptool copy output/smartmini-bullseye.img.xz /dev/sdc --nobmap

## License rules

This project is provided under the terms of the GPLv2 license as provided in the COPYING file.

Instead of adding GPLv2 boilerplates to the individual files, we uses SPDX license identifiers,
which are machine parseable and considered legaly equivalent.
