# Vmdb2-image-smartmini-tx6

This repository contains the basic tools to generate a Mfg-Tool archive to flash a minimal debian bullseye on a smartmini type device.

Instructions for configuration and use of hardware and software components can be found in the `doc` subdirectory.

## Required packages for building the image (incl. the kernel)

    sudo apt install bison flex bc lzop gcc-arm-linux-gnueabihf vmdb2 dosfstools qemu-user-static binfmt-support time kpartx bmap-tools

## Generating MfgTools

To generate a MfgTool to flash a minimal Debian Single Root on either a SmartRail or an SmartMini execute the script:

    ./buildall.py

The generated compressed archives of the Mfg Tools can be found under `output/build-<recent timestamp>/mfg/`.

### Flashing the image to the SD-card

    lsblk

=> Find device file of YOUR sd-card device ...

    sudo bmaptool copy output/smartmini-bullseye.img.xz /dev/sdc --nobmap

### License rules

This project is provided under the terms of the GPLv2 license as provided in the COPYING file.

Instead of adding GPLv2 boilerplates to the individual files, we uses SPDX license identifiers, which are machine parseable and considered legaly equivalent.
