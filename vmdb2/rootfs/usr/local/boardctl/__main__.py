#!/usr/bin/env python3
# Copyright (C) 2021  optiMEAS GmbH. All rights reserved.
#
# SPDX-License-Identifier: GPL-2.0-only

# small script to power on and off a gci modem on the smartrail
# board

import gpiod
import argparse
import time
import sys

from typing import Final


class ModemControl:
    def __init__(self):
        self.chip3: Final = gpiod.Chip("20a8000.gpio") 
        self.chip4: Final = gpiod.Chip("20ac000.gpio")

        self.PWRKEY: Final = self.chip3.get_line(11)
        self.DCDC_PIN: Final = self.chip4.get_line(19)

        self.PWRKEY.request(consumer=sys.argv[0], type=gpiod.LINE_REQ_DIR_OUT)
        self.DCDC_PIN.request(consumer=sys.argv[0], type=gpiod.LINE_REQ_DIR_OUT)

    def poweron(self):
        self.DCDC_PIN.set_value(0)
        time.sleep(0.150)

        self.PWRKEY.set_value(1)
        time.sleep(0.150)
        self.PWRKEY.set_value(0)

    def poweroff(self):
        self.DCDC_PIN.set_value(1)
        self.PWRKEY.set_value(0)
        time.sleep(0.150)

def setup_parser(modem: ModemControl) -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description='optimeas device control utility')
    subparsers = parser.add_subparsers()
    parser_modem = subparsers.add_parser('modem')

    modem_subparsers = parser_modem.add_subparsers()

    parser_modem_on = modem_subparsers.add_parser('on')
    parser_modem_on.set_defaults(func=modem.poweron)

    parser_modem_off = modem_subparsers.add_parser('off')
    parser_modem_off.set_defaults(func=modem.poweroff)

    return parser


def main() -> None:
    modem = ModemControl()

    parser = setup_parser(modem)

    if len(sys.argv) <= 1:
        sys.argv.append('--help')

    options = parser.parse_args()

    options.func()


if __name__ == "__main__":
    main()
