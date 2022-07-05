#!/bin/bash
# Copyright (C) 2021  optiMEAS GmbH. All rights reserved.
#
# SPDX-License-Identifier: GPL-2.0-only

function transceiver_on()
{
    echo $1 > /sys/class/gpio/export
    echo out > /sys/class/gpio/gpio${1}/direction
    echo 0 > /sys/class/gpio/gpio${1}/value
    echo $1 > /sys/class/gpio/unexport
}

transceiver_on 2
transceiver_on 5