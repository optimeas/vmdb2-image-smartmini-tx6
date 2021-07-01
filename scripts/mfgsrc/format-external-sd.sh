#!/bin/sh

# Script from old BSP for formating external SD cards during install procedure.

EMMC_DEVICE="/dev/$(readlink /dev/emmc)p1"
declare -a MMC_DEVICES=("/dev/mmcblk0" "/dev/mmcblk1" "/dev/mmcblk2")

for m in "${MMC_DEVICES[@]}"
do
  if [ -b "${m}" ]; then
    echo "#### FORMAT MMC DEVICE: $m ####"

    if [ "${m}p1" == "${EMMC_DEVICE}" ]; then
      echo "$m is the eMMC device! We skip this one ..."
    else
      echo "Formating device $m ..."
      dd if=/dev/zero of=${m} bs=1024 count=1024
      sync
      sleep 2

      # Aligned to 4 MiB erase group size (8192 x 512 byte sectors)
      (echo unit:sectors; echo label-id:0x12345678; echo start=8192,type=83) | sfdisk -f ${m}

      # stride= NAND Page        Size in File System Blocks (4096 Byte) => 4 KiB
      # stride= NAND Erase Block Size in File System Blocks (4096 Byte) => 4 MiB
      mkfs.ext4 -FF -L "extdata" -E stride=1,stripe-width=1024 ${m}p1
      SD_CARD_FORMATTED="1"
    fi
  fi
done

if [ -z "${SD_CARD_FORMATTED}" ]; then
  echo "#### FATAL ERROR: no external SD card found !!! ####" 
  exit -1
fi