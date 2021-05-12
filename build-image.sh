#!/bin/bash
# Copyright (C) 2021  optiMEAS GmbH. All rights reserved.
#
# SPDX-License-Identifier: GPL-2.0-only

OPT_CREATE_COMPRESSED_IMAGE=0
OPT_INCREMENTAL_BUILD=0
while getopts xi opt
do
    case $opt in
    x) OPT_CREATE_COMPRESSED_IMAGE=1;;
    i) OPT_INCREMENTAL_BUILD=1;;
    esac
done


MYDIR=$(pwd)

VMDB2_DIR="vmdb2"
VMDB2_YAML_FILE="smartmini-bullseye.yaml"
VMDB2_LATEST_DIR="vmdb2-latest"

DEB_DIR="debian-packages"
OUTPUT_PATH="${MYDIR}/output"
VMDB2_YAML_FILE_WITHOUT_EXTENSION="${VMDB2_YAML_FILE%.*}"

VMDB2_LOG_FILE="${OUTPUT_PATH}/${VMDB2_YAML_FILE_WITHOUT_EXTENSION}-$(date +"%Y_%m_%d__%H_%M_%S").log"
VMDB2_ROOTFS_CACHE_FILE="${OUTPUT_PATH}/${VMDB2_YAML_FILE_WITHOUT_EXTENSION}-rootfs-cache.tar.gz"
VMDB2_IMAGE_FILE="${OUTPUT_PATH}/${VMDB2_YAML_FILE_WITHOUT_EXTENSION}.img"
VMDB2_COMPRESSED_IMAGE_FILE="${VMDB2_IMAGE_FILE}.xz"

INSTALLER_NAME=installer-image
INSTALLER_IMAGE="${OUTPUT_PATH}/${INSTALLER_NAME}.img"
INSTALLER_ROOTFS_CACHE="${OUTPUT_PATH}/${INSTALLER_NAME}-rootfs-cache.tar.gz"
INSTALLER_YAML="${MYDIR}/${VMDB2_DIR}/${INSTALLER_NAME}.yaml"
INSTALLER_LOG="${OUTPUT_PATH}/${INSTALLER_NAME}-$(date +"%Y_%m_%d__%H_%M_%S").log"

ROOTFS="${MYDIR}/${VMDB2_DIR}/rootfs"

if [ ! -d "$OUTPUT_PATH" ]; then
	echo "creating output directory $OUTPUT_PATH"
    mkdir ${OUTPUT_PATH}
fi

cd ${VMDB2_DIR}
set -ex

if ! compgen -G "${DEB_DIR}/linux-image-*.deb" > /dev/null; then
    echo "downloading kernel"
    cd ${DEB_DIR}
    
	wget https://buildserver.optimeas.de/artifacts/debian/linux-image-tx6-latest.deb
	
	cd ${MYDIR}/${VMDB2_DIR}
fi

if [ ! -d ${VMDB2_LATEST_DIR} ]; then 
    git clone git://git.liw.fi/vmdb2 ${VMDB2_LATEST_DIR}
fi

if [ $OPT_INCREMENTAL_BUILD = 0 ]; then
    [ -f ${VMDB2_ROOTFS_CACHE_FILE} ] && sudo rm -f ${VMDB2_ROOTFS_CACHE_FILE}
    [ -f ${INSTALLER_ROOTFS_CACHE} ] && sudo rm -f ${INSTALLER_ROOTFS_CACHE}
fi

# generate imageinfo.txt for this build
BRANCHNAME=$(git symbolic-ref HEAD | awk -F'/' '{print $3}')
GITVERSION=$(git describe)
IMAGE_RELEASE=bullseye

BUILD_DATE=$(date -Iseconds)
IMAGE_NAME="vmdb2-${VMDB2_YAML_FILE_WITHOUT_EXTENSION}"
MACHINE=smartmini-8035
IMAGE_VERSION="debian-${IMAGE_RELEASE}-${BRANCHNAME}-${GITVERSION}"

echo -e "BUILD_DATE=${BUILD_DATE}
IMAGE=${IMAGE_NAME}
MACHINE=${MACHINE}
VERSION=${IMAGE_VERSION}
" > ${ROOTFS}/etc/imageinfo.txt

# u-boot script creation
UBOOT_SCRIPT_MMC=${MYDIR}/scripts/u-boot-mmc.script
MMC_SCRIPT_DIR=${MYDIR}/vmdb2/rootfs/boot
UBOOT_SCRIPT_INST=${MYDIR}/scripts/u-boot-installer.script
INST_SCRIPT_DIR=${MYDIR}/vmdb2/installer/

# prepare target MMC u-boot script
sudo mkimage -A arm -T "script" -C none -n "Boot Script" -d "${UBOOT_SCRIPT_MMC}" u-boot.scr
mkdir -p ${MMC_SCRIPT_DIR}
rm -f ${MMC_SCRIPT_DIR}/u-boot.scr
mv u-boot.scr ${MMC_SCRIPT_DIR}

# prepare installer u-boot script 
sudo mkimage -A arm -T "script" -C none -n "Boot Script" -d "${UBOOT_SCRIPT_INST}" u-boot.scr
mkdir -p ${INST_SCRIPT_DIR}
rm -f ${INST_SCRIPT_DIR}/u-boot.scr
mv u-boot.scr ${INST_SCRIPT_DIR}

# Build the Target Image
sudo rm -f ${VMDB2_IMAGE_FILE} ${VMDB2_COMPRESSED_IMAGE_FILE}
time sudo ${VMDB2_LATEST_DIR}/vmdb2 --verbose --rootfs-tarball=${VMDB2_ROOTFS_CACHE_FILE} --output ${VMDB2_IMAGE_FILE} ${VMDB2_YAML_FILE} --log ${VMDB2_LOG_FILE}

# Build installer image
sudo rm -f ${INSTALLER_IMAGE} 
time sudo ${VMDB2_LATEST_DIR}/vmdb2 --verbose --rootfs-tarball=${INSTALLER_ROOTFS_CACHE} --output ${INSTALLER_IMAGE} ${INSTALLER_YAML} --log ${INSTALLER_LOG}

if [ $OPT_CREATE_COMPRESSED_IMAGE = 1 ]  ; then
    xz -k ${VMDB2_IMAGE_FILE}
    xz -k ${INSTALLER_IMAGE}
fi

