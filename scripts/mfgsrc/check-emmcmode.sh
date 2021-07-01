#!/bin/sh

# Script for checking and enabling PSLC mode and watchdog control.

boardinfo=`cat /proc/cmdline`

# When the powerc application throws an exception, the MfgTool stop the flash process with an error message
# Therfore we have to take care to call it only on supported platforms ...
powerc () {
    echo "Parameter #1 is $1"

	if [[ $boardinfo == *8013* ]]; then
		ln -sf /dev/i2c-0 /dev/i2c-2
	fi

    if [[ $boardinfo == *smartpro* ]]; then
        ./powerc smartpro $1
        ./powerc smartpro $1
        ./powerc smartpro $1
        ./powerc smartpro $1
	fi

    if [[ $boardinfo == *smartmini* ]]; then
        ./powerc smartmini $1
        ./powerc smartmini $1
        ./powerc smartmini $1
        ./powerc smartmini $1
	fi

    if [[ $boardinfo == *smartrail* ]]; then
        ./powerc smartmini $1
        ./powerc smartmini $1
        ./powerc smartmini $1
        ./powerc smartmini $1
	fi

    if [[ $boardinfo == *aclavis* ]]; then
        echo "INFO: aclavis board has no power controller"
	fi

    if [[ $boardinfo == *bekolog* ]]; then
        echo "TODO: add suppport for BekoLog board"
	fi

    if [[ $boardinfo == *smartdemo* ]]; then
        echo "TODO: add suppport for smartDEMO board"
	fi
}

if [[ $boardinfo == *smartmini* ]]; then
    echo "#### PSEUDO SLC MODE IS CURRENTLY NOT AVAILABLE FOR SMARTMINI ####"
    echo "#### SKIPPING PSEUDO SLC ACTIVATION ###"
    exit 0
fi

if [ $(mmc extcsd read /dev/emmc | sed '/PARTITION_SETTING_COMPLETED/!d;s/^.* //;s/[^0-9a-fx]*//gi') == 0x00 ]
    then
      echo "#### ENABLE PSEUDO SLC MODE ####"

      MAX_ENH_SIZE_MULT=$(mmc extcsd read /dev/emmc | sed '/MAX_ENH_SIZE_MULT/!d;s/^.* //')
      HC_WP_GRP_SIZE=$(mmc extcsd read /dev/emmc | sed '/HC_WP_GRP_SIZE/!d;s/^.* //;s/[^0-9a-fx]*//gi')
      HC_ERASE_GRP_SIZE=$(mmc extcsd read /dev/emmc | sed '/HC_ERASE_GRP_SIZE/!d;s/^.* //;s/[^0-9a-fx]*//gi')

      ENH_AREA_SIZE=$(( ${MAX_ENH_SIZE_MULT} * ${HC_WP_GRP_SIZE} * ${HC_ERASE_GRP_SIZE} * 512))
      echo "#### NEW EMMC SIZE: ${ENH_AREA_SIZE} KiB ####"

      printf "\n#### WRITING THE ENHANCED USER AREA ... ####"
      mmc enh_area set -y 0 ${ENH_AREA_SIZE} /dev/emmc

      echo ""
      echo ""
      echo "***********************************************************"
      echo "* DONE - POWER CYCLE NEEDED TO START SECOND FLASH STEP ! *"
      echo "***********************************************************"
      echo ""
      echo ""
      powerc power
else
      echo "#### PSEUDO SLC MODE IS ALREADY CONFIGURED ####"
      powerc disable
fi
