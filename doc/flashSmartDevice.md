# Flashing a smartMINI/smartRAIL

This document describes how to flash a smartMINI or a smartRAIL using a Mfg-Tool.

## Requirements

### **Hardware:**

* smartRAIL/smartMINI + power supply
* 1x Jumper or any other similar tool (e.g a metal paperclip)

Device dependent hardware:

**smartRAIL**

* 1x USB Typ-A to Typ-B Micro
* Screwdriver for TX10 screws (front panel) and TX20 (cooler) screws
  
OR

**smartMINI**

* 1x USB Typ-A to Typ-B Mini
* Screwdriver for TX10 (front panel)

### **Software:**

* Windows Host
* Optimeas Mfg-Archive

**Hint**: To flash the device access to the four contacts located onboard is needed (and the onbaord HID interface on the smartRAIL),
i.e the device needs to be removed from the case.

## Flashing the device

1. Before connecting the device to a power supply, connect the 2 pins nearest to the COM-Module with the jumper (pictures showcasing this step at the bottom)
2. Connect the device to a power supply
3. Connect your Windows System to the USB HID interface
4. Untar the Mfg-Tool archive on your Windows host and run MfgTool2.exe
5. Press start and wait some minutes until both bars turn green
6. Close the tool and remove the jumper and the USB cable from the device
7. Restart the device by disconnecting and reconnecting it to the power supply

The device will now boot into the newly flashed linux environment.

## Illustrations

Pictures to showcase steps from the flash process

* [Jumper position on smartMINI](./res/smartMINI_mfg-tool.jpg)