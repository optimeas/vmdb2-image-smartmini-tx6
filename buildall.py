#!/usr/bin/env python3
# Copyright (C) 2021  optiMEAS GmbH. All rights reserved.
#
# SPDX-License-Identifier: GPL-2.0-only

import json
import os
import datetime
import subprocess
import copy
import shutil
import urllib.request
import tarfile
import re
from pathlib import Path


class RootAlreadyBuilt(Exception):
    pass


class SpeciNotFound(Exception):
    pass


default_config = {
    "root": os.getcwd(),
    "buildCfg": "boards.json",
    "mfgtxPATH": "mfgtx",
    "outputPATH": "output",
    "archBinPATH": "archBin",
}


def image_identifier(buildCfg: dict)-> str:
    filename = buildCfg['vmdb2Root']
    name = filename.split('.')[0]
    name = '-'.join(filename.split('-')[-2:])
    return name

class ConfigProvider:
    def __init__(self, cfgPath: str) -> None:
        if not os.path.exists(cfgPath):
            self.genDefaultCfg(cfgPath)
        
        with open(cfgPath, "r") as file:
            self.appCfg = json.load(file)
            self.buildCfg = self.parseBuildConfig(self.appCfg["buildCfg"])

            for key in self.appCfg:
                if not os.path.isabs(self.appCfg[key]):
                    self.appCfg[key] = os.path.join(self.appCfg["root"], self.appCfg[key])

    def genDefaultCfg(self, dest: str):
        with open(dest, "w") as file:
            json.dump(default_config, file, indent=2)

    def parseBuildConfig(self, file: str) -> list:
        with open(file, 'r') as f:
            data = json.load(f)

        # split different device trees into seperate configs
        for index in range(0, len(data)):
            con = data[index]

            if type(con["deviceTree"]) == list:
                dtbs = con["deviceTree"]
                con["deviceTree"] = dtbs[0]

                for i in range(1, len(dtbs)):
                    cc = copy.copy(con)
                    cc["deviceTree"] = dtbs[i]
                    data.append(cc)

            data[index] = con

        # append members to all configs that are devirations of already
        # existing members
        for index in range(0, len(data)):
            con = data[index]

            con["board"] = '-'.join(con["deviceTree"].split('-')[1:3])
            con["cpu"] = con["deviceTree"].split('-')[0]
            con["device"] = '-'.join(con["deviceTree"].split('-')[-2:])

            data[index] = con

        return data


def buildRootVmdb2(dir: str, buildCfg: dict) -> str:
    """call build-image.sh with dir as output directory and config["vmdb2Root"]
    as specifile
    """
    buildRoot = Path(dir) / os.path.basename(buildCfg["vmdb2Root"]).split('.', 1)[0]

    workingDir = Path.cwd()
    specifile = workingDir / "vmdb2" / buildCfg["vmdb2Root"]

    if not specifile.is_file():
        raise SpeciNotFound

    if not buildRoot.is_dir():
        os.mkdir(buildRoot)

        cmd = ['sudo', './build-image.sh', '-f', specifile, '-d', buildRoot]
        proc = subprocess.run(cmd)

        try:
            proc.check_returncode()
 
        except subprocess.CalledProcessError as e:
            raise e

    else:
        raise RootAlreadyBuilt


def pullMFGTXBinary(dir: str):
    cmd = ['git', 'clone', 'https://github.com/optimeas/mfgtool-tx6.git', dir]

    subprocess.run(cmd)


def copyTemplatesToMfgTree(mfgSrcDir: str, mfgTree: str, buildCfg: dict):
    join = os.path.join

    profileDir = join(mfgTree, "Profiles", buildCfg["mfgProfile"])

    files = {
        join(mfgSrcDir, "cfg.ini.template"): join(mfgTree, "cfg.ini"),
        join(mfgSrcDir, "check-emmcmode.sh"):
            join(profileDir, "custom/check-emmcmode.sh"),
        join(mfgSrcDir, buildCfg["mfgUCL"]): join(profileDir, "OS Firmware/ucl2.xml"),
        join(mfgSrcDir, "powerc"): join(profileDir, "custom/powerc"),
        join(mfgSrcDir, "format-external-sd.sh"): join(profileDir, "custom/format-external-sd.sh"),
        join(mfgSrcDir, "u-boot.env.template"): join(profileDir, "custom/u-boot.env"),
        join(mfgSrcDir, "mfg.env.template"): join(profileDir, "OS Firmware/mfg.env")
    }

    for key, val in files.items():
        shutil.copy2(key, val)


def replaceTokens(string: str, buildCfg: dict) -> str:
    """Replaces all occurrences of "{{x}}" in string
    with the stored value of buildCfg["x"].
    Applying that x can be any string not containing { or } characters.
    
    For example by passing the string "{{mach}}" the return value
    will be the value stored at the index of buildCfg["mach"]
    """
    result = str()
    regex = re.compile("{{([^}{]*)}}")
    currentOffset = 0

    for match in regex.finditer(string):
        cfgIndex = match.group(1)
        result += string[currentOffset:match.start()] + buildCfg[cfgIndex]

        currentOffset = match.end()

    result += string[currentOffset:]

    return result


def parseTemplate(file: str, buildCfg: dict) -> None:
    with open(file, 'r+') as f:
        result = replaceTokens(f.read(), buildCfg)
        f.seek(0)
        f.write(result)
        f.truncate()


def parseTemplates(mfgTree: str, buildCfg: dict):
    """parses files inside mfgTree with Data taken out of config"""
    parseTemplate(os.path.join(mfgTree, "cfg.ini"), buildCfg)
    parseTemplate(os.path.join(mfgTree, "Profiles", buildCfg["mfgProfile"], "OS Firmware/mfg.env"), buildCfg)
    parseTemplate(os.path.join(mfgTree, "Profiles", buildCfg["mfgProfile"], "custom/u-boot.env"), buildCfg)


def pullUbootBinaries(dest: str):
    os.makedirs(dest)

    tarball = os.path.join(dest, "u-boot-tx6-latest.tgz")
    url = "https://buildserver.optimeas.de/artifacts/debian/u-boot-tx6-latest.tgz"
    urllib.request.urlretrieve(url, tarball)

    tar = tarfile.open(tarball, "r:gz")

    tar.extractall(dest)

    os.remove(tarball)


def buildMFGTool(mfgRoot: str, buildCfg: dict, appCfg: dict) -> os.PathLike[str]:
    """build a MFGtool directory inside mfgRoot following the configuration inside
    buildCfg and appCfg
    """
    basename = buildCfg["mach"] + '-' + buildCfg["deviceTree"].split('-')[-1] + '-' + image_identifier(buildCfg)
    mfgDir = Path(mfgRoot) / basename

    mfgSrcDir = Path.cwd() / "scripts" / "mfgsrc"

    # copy mfgtx binary template into mfg build tree
    shutil.copytree(os.path.join(os.getcwd(), "mfgtx"), mfgDir)
    shutil.rmtree(os.path.join(mfgDir, ".git"))

    # copy mfg template files into mfg build tree
    copyTemplatesToMfgTree(mfgSrcDir, mfgDir, buildCfg)
    parseTemplates(mfgDir, buildCfg)

    # copy board-specific files into mfg build tree
    uboot = os.path.join(appCfg["archBinPATH"], 
                            "u-boot-" + '-'.join(buildCfg["deviceTree"].split('-')[1:]) + ".bin")
    shutil.copy2(uboot, 
                    os.path.join(mfgDir, "Profiles", buildCfg["mfgProfile"], "custom","u-boot.bin"))

    # copy vmdb rootfs into tree
    rootfs = os.path.join(os.path.dirname(mfgRoot),"vmdb2",buildCfg["vmdb2Root"].split('.')[0],
    "rootfs.tar")
    shutil.copy2(rootfs, os.path.join(mfgDir, "Profiles", buildCfg["mfgProfile"], "custom"))

    return mfgDir


def tarDir(target: str, dest: str):
    with tarfile.open(dest, "w:gz") as tar:
        tar.add(target, arcname=os.path.basename(target))


def main():
    cfg = ConfigProvider("builder.conf")

    if not os.path.isdir(cfg.appCfg["mfgtxPATH"]):
        pullMFGTXBinary(cfg.appCfg["mfgtxPATH"])

    # pull architecture dependent binaries (u-boot.bin)
    if not os.path.exists(cfg.appCfg["archBinPATH"]):
        try:
            pullUbootBinaries(cfg.appCfg["archBinPATH"])
        except urllib.error.HTTPError as e:
            print(e)
            print(e.headers)
            shutil.rmtree(cfg.appCfg["archBinPATH"])
            raise SystemExit

        except Exception as e:
            print(e)
            shutil.rmtree(cfg.appCfg["archBinPATH"])
            raise SystemExit

    # prepare the build tree for the build
    now = datetime.datetime.now()
    timestamp = now.strftime('%y-%m-%d-%H%M%S')

    buildRoot = os.path.join(cfg.appCfg["outputPATH"], "build-{}".format(timestamp))
    os.mkdir(buildRoot)

    mfgRoot = os.path.join(buildRoot, "mfg")
    os.mkdir(mfgRoot)

    vmdb2Root = os.path.join(buildRoot, "vmdb2")
    os.mkdir(vmdb2Root)

    # build the artifacts after the configs from ConfigFile
    for con in cfg.buildCfg:
        if con["enabled"]:
            try:
                buildRootVmdb2(vmdb2Root, con)
            except RootAlreadyBuilt:
                pass
            except SpeciNotFound:
                continue

            uncompressed_mfgDir = buildMFGTool(mfgRoot, con, cfg.appCfg)   

            target = uncompressed_mfgDir.with_suffix('.tgz')
            tarDir(uncompressed_mfgDir, target)
            shutil.rmtree(uncompressed_mfgDir)


if __name__ == "__main__":
    main()
