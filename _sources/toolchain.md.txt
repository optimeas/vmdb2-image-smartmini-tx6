# Building a application for a smartRail or smartMini with Debian

This file describes the different ways to compile an C/C++ Application for your
target optiMEAS Debian device using either one of the following methods:

* QEMU emulated armhf system inside a docker container
* building the application natively on the target device
* a debian sysroot for crosscompile builds on your host system

## Defintions and overall requirements

You need a up-to-date Debian Bullseye(stable) system installed on your host.

The package requirements are listed inside each subsection for a specific development
method.

## Method 1: Using QEMU Emulation with docker

Install the following packages:

    sudo apt install docker-ce docker-ce-cli qemu binfmt-support qemu-user-static

Add the your user to the docker group

    sudo usermod user -a -G docker

Then execute the script `toolchain/bullseye-minimal-armhf-emulated/build.sh` to build the container.

**Hint:** If the scripts fails with dns name resolution errors, you may need to specify the dns servers
which the docker daemon should use. You can do this by writing the following structure

    {
        "dns":["8.8.8.8","10.20.30.40"]
    }

into `/etc/docker/daemon.json` and restarting the docker daemon.

    sudo systemctl restart docker

After the container has been successfully built, execute the 
`toolchain/bullseye-minimal-armhf-emulated/run-shell.sh` script once.

The current docker setup consists of the `~/debian-builds` directory that is mounted
inside the container if you start a shell via the `run-shell.sh`, where you can store
your development projects.

## Method 2: Native build on the target device

Documentaion TBD...


## Method 3: Crosscompiling using a debian sysroot

This method is to be implemented in the future...