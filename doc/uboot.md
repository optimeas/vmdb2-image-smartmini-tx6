# U-Boot configuration

Starting with a U-Boot from our Yocto image (in the eMMC), the following variables need to be adjusted:

setenv bootcmd 'ext4load mmc 1:1 30000000 /boot/u-boot.scr; source 30000000'
saveenv

