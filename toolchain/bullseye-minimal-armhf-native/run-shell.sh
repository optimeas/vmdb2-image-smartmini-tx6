#!/bin/bash

# docker hub username
USERNAME=optimeas
# image name
IMAGE=debian-build-armhf-native
# version
VERSION=bullseye

if [ -z "$1" ]; then
  WORK_DIR=~/debian-builds
else
	# ${1%/} => first agrument without trailing slash
	WORK_DIR=${1%/}
fi

WORK_DIR_ABS=$(readlink -f $WORK_DIR)

if [ ! -d "$WORK_DIR_ABS" ]; then
	echo "creating working directory $WORK_DIR_ABS"
	mkdir ${WORK_DIR_ABS}
	chmod 2775 ${WORK_DIR_ABS}
	setfacl -d -m group:5000:rwx ${WORK_DIR_ABS}
	setfacl -m group:5000:rwx ${WORK_DIR_ABS}
else
	echo "using working directory $WORK_DIR_ABS"
fi

set -ex
docker run --platform linux/arm/v7 -it --rm -v $WORK_DIR_ABS:/work -w /work $USERNAME/$IMAGE:$VERSION

