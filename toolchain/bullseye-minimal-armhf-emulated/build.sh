#!/bin/bash

set -ex

# docker hub username
USERNAME=optimeas
# image name
IMAGE=debian-build-armhf-emulated
# version
VERSION=bullseye

docker build --platform linux/arm/v7 -t $USERNAME/$IMAGE:$VERSION .
