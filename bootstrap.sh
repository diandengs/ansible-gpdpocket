#!/bin/bash

# set exit on error
set -e

# Set branch
if [ "$1" == '--dev' ]; then
  BRANCH=dev
else
  BRANCH=master
fi

# copy wifi config
echo "copying wifi config..."
mkdir -p /lib/firmware/brcm
cp -f roles/wifi/files/brcmfmac4356-pcie.* /lib/firmware/brcm/

# enable wifi
echo "enabling wifi..."
modprobe -r brcmfmac
modprobe brcmfmac

# prompt for wifi connection
echo "If you do not see the WiFi option in your desktop environment - you may need to use a USB ethernet adapter. This is due to an incompatibility on the Linux kernel your distribution is using. This will be resolved once the bootstrap script has run successfully for the first time but that will require an Internet connection to be present."
echo
echo "Please connect to a WiFi network or wired network (via USB adapter), then press return to continue:"
read

# wait for internet connection
echo "waiting for internet connection..."
while ! ping -c1 pool.ntp.org &>/dev/null; do
  sleep 1
done

# install essential packages
echo "installing essential packages..."
if [ -f /usr/bin/pacman ]; then
  pacman -Sy --noconfirm ansible git
elif [ -f /usr/bin/apt-get ]; then
  while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
    sleep 1
  done
  apt-get update
  apt-get -y install software-properties-common python-software-properties
  add-apt-repository -y ppa:ansible/ansible
  apt-get update
  apt-get -y install ansible git
elif [ -f /usr/bin/emerge ]; then
  emerge --sync
  USE="blksha1 curl webdav" emerge app-admin/ansible dev-vcs/git
fi

# update ansible code
echo "downloading latest ansible code..."
git clone https://github.com/cawilliamson/ansible-gpdpocket.git /usr/src/ansible-gpdpocket
cd /usr/src/ansible-gpdpocket
git fetch --all
git reset --hard origin/${BRANCH}

# ensure /boot is mounted
echo "ensuring /boot is mounted..."
mount /boot >/dev/null 2>&1 || true

# run ansible scripts
echo "starting ansible playbook..."
ANSIBLE_NOCOWS=1 ansible-playbook site.yml

# reboot
echo "starting reboot..."
reboot