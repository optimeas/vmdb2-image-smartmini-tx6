#!/bin/bash
# Copyright (C) 2021  optiMEAS GmbH. All rights reserved.
#
# SPDX-License-Identifier: GPL-2.0-only

SNAME=generate-ssh-host-keys.service

# delete and restore host keys
if [ -d /etc/ssh ]; then
    rm -f /etc/ssh/ssh_host*
fi

ssh-keygen -A

# Disable this service so reconfigruation will not happen again

systemctl disable ${SNAME}
