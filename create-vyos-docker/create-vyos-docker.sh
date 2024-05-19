#!/bin/bash
mkdir vyos && cd vyos
echo "install jq"
sudo apt install jq -y > /dev/null 2>&1
LATEST=$(curl https://api.github.com/repos/vyos/vyos-rolling-nightly-builds/releases/latest ) > /dev/null 2>&1
DOWNLOAD_URL=$(echo $LATEST |  jq -r '.assets[].browser_download_url'   | grep '.iso$')
TARGET=$(echo $LATEST |   jq -r '.assets[].name'   | grep '.iso$')
VERSION=$(echo $LATEST |  jq -r '.name' )
echo "create  vyos:$VERSION"
if [ ! -e $TARGET ]; then
  echo "download $VERSION"
  wget $DOWNLOAD_URL
fi

# https://docs.vyos.io/en/latest/installation/virtual/docker.html#deploy-container-from-iso
mkdir rootfs
sudo mount -o loop $TARGET  rootfs
sudo apt install -y squashfs-tools  > /dev/null 2>&1
mkdir unsquashfs
sudo unsquashfs -f -d unsquashfs/ rootfs/live/filesystem.squashfs
sudo tar -C unsquashfs -c . | sudo docker import - vyos:$VERSION 
sudo docker tag vyos:$VERSION vyos:latest
sudo umount rootfs


