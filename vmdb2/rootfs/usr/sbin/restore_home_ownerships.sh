#!/bin/bash
# Copyright (C) 2021  optiMEAS GmbH. All rights reserved.
#
# SPDX-License-Identifier: GPL-2.0-only

set -e


function isAHomeDir()
{
    echo $(grep /home/${1} /etc/passwd)
}

COUNT=0
DIRECTORIES=$(ls /home)

for dir in ${DIRECTORIES}; do
    if [[ $(isAHomeDir ${dir}) ]] ; then
        chown -Rc ${dir}:${dir} /home/${dir}
    fi   
done