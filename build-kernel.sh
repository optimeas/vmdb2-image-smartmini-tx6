#!/bin/bash
# Copyright (C) 2021  optiMEAS GmbH. All rights reserved.
#
# SPDX-License-Identifier: GPL-2.0-only

MYDIR=$(pwd)

KERNEL_DIR="kernel"
VMDB2_DIR="vmdb2"
DEB_DIR="${VMDB2_DIR}/debian-packages"

KERNEL_CROSS_COMPILE="arm-linux-gnueabihf-"
KERNEL_LD="arm-linux-gnueabihf-ld.bfd"

set -ex

if [ ! -d "$KERNEL_DIR" ]; then
	echo "prepare kernel directory"
    git clone https://github.com/optimeas/linux-tx6-4.14.git ${KERNEL_DIR}

    mkdir -p ${KERNEL_DIR}/imx/sdma
    cp -v sdma-imx6q.bin ${KERNEL_DIR}/imx/sdma/
    cp -v ${MYDIR}/kernel-config ${KERNEL_DIR}/.config
    
    cd ${KERNEL_DIR}
    make ARCH=arm CROSS_COMPILE="${KERNEL_CROSS_COMPILE}" LD="${KERNEL_LD}" olddefconfig

    cd ${MYDIR}
fi

cd ${KERNEL_DIR}

#TODO: add a command line option "-c" to clean the tree with "make mrproper"

#make ARCH=arm CROSS_COMPILE="${KERNEL_CROSS_COMPILE}" LD="${KERNEL_LD}" zImage
#make ARCH=arm CROSS_COMPILE="${KERNEL_CROSS_COMPILE}" LD="${KERNEL_LD}" modules
#make ARCH=arm CROSS_COMPILE="${KERNEL_CROSS_COMPILE}" LD="${KERNEL_LD}" dtbs

make ARCH=arm CROSS_COMPILE="${KERNEL_CROSS_COMPILE}" LD="${KERNEL_LD}" bindeb-pkg

rm -f ${MYDIR}/${DEB_DIR}/linux-image-*.deb
cp -v ../linux-image-*.deb ${MYDIR}/${DEB_DIR}/linux-image-tx6-latest.deb

