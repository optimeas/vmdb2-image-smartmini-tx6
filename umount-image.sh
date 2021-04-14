#!/bin/bash
# Copyright (C) 2021  optiMEAS GmbH. All rights reserved.
#
# SPDX-License-Identifier: GPL-2.0-only

MYDIR=$(pwd)

#LOOP_DEVICE=$1
LOOP_DEVICE=0

DEVICE="/dev/loop${LOOP_DEVICE}"
for PARTITION in "${DEVICE}"?*; do
    if [ "$PARTITION" = "${DEVICE}p*" ]; then
        PARTITION="${DEVICE}"
    fi
    DESTINATION="/mnt/$(basename "${PARTITION}")"
    sudo umount "$DESTINATION"
    sudo rm -rf $DESTINATION
done
sudo losetup -d "$DEVICE"
