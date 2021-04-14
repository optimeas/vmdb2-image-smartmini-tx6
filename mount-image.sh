#!/bin/bash
# Copyright (C) 2021  optiMEAS GmbH. All rights reserved.
#
# SPDX-License-Identifier: GPL-2.0-only

MYDIR=$(pwd)

IMAGE_FILE=$1

DEVICE="$(sudo losetup --show -f -P "${IMAGE_FILE}")"
echo "${DEVICE}"
for PARTITION in "${DEVICE}"?*; do
    if [ "$PARTITION" = "${DEVICE}p*" ]; then
        PARTITION="${DEVICE}"
    fi
    
    DESTINATION="/mnt/$(basename "$PARTITION")"
    echo "$DESTINATION"
    
    sudo mkdir -p "$DESTINATION"
    sudo mount "$PARTITION" "$DESTINATION"
done

