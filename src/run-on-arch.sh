#!/bin/bash

set -eo pipefail

ARCH=$1
DISTRO=$2
COMMANDS=$3
COMMANDS="${COMMANDS//[$'\t\r\n']+/;}" #Replace newline with ;
ADDITIONAL_ARGS=$4
QEMU_VERSION=4.2.0-6

# Install support for new archs via qemu
# Platforms: linux/amd64, linux/arm64, linux/riscv64, linux/ppc64le, linux/s390x, linux/386, linux/arm/v7, linux/arm/v6
#sudo apt update -y && sudo apt install -y qemu qemu-user-static

#sudo apt update -y 
#curl -L https://github.com/multiarch/qemu-user-static/releases/download/v${QEMU_VERSION}/x86_64_qemu-s390x-static.tar.gz | tar zxvf - -C /usr/bin
#chmod +x /usr/bin/qemu-*
#curl -L https://github.com/multiarch/qemu-user-static/releases/download/v${QEMU_VERSION}/qemu-$ARCH-static.tar.gz 
#sudo tar zxvf qemu-$ARCH-static.tar.gz -C /usr/bin

ACT_PATH=$(dirname $(dirname $(readlink -fm "$0")))

docker run --rm --privileged multiarch/qemu-user-static:4.2.0-6 --reset -p yes
docker build . --file $ACT_PATH/Dockerfiles/Dockerfile.$ARCH.$DISTRO --tag multiarchimage 

sudo apt update -y && sudo apt install -y git

docker run \
  --workdir /github/workspace \
  --rm \
  --privileged \
  -e HOME=/github/home \
  -e GITHUB_REF \
  -e GITHUB_SHA \
  -e GITHUB_REPOSITORY \
  -e GITHUB_ACTOR \
  -e GITHUB_WORKFLOW=/github/workflow \
  -e GITHUB_HEAD_REF \
  -e GITHUB_BASE_REF \
  -e GITHUB_EVENT_NAME \
  -e GITHUB_WORKSPACE=/github/workspace \
  -e GITHUB_ACTION \
  -e GITHUB_EVENT_PATH \
  -e RUNNER_OS \
  -e RUNNER_TOOL_CACHE \
  -e RUNNER_TEMP \
  -e RUNNER_WORKSPACE \
  -v "/home/runner/work/_temp/_github_home":"/github/home" \
  -v "/home/runner/work/_temp/_github_workflow":"/github/workflow" \
  -v "${PWD}":"/github/workspace" \
  $ADDITIONAL_ARGS \
  -t multiarchimage \
  /bin/bash -c "$COMMANDS"
