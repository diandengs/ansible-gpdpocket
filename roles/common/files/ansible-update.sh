#!/bin/bash

# set exit on error
set -e

# Set branch
if [ "$1" == '--dev' ]; then
  BRANCH=dev
else
  BRANCH=master
fi

# wait for internet connection
echo "waiting for internet connection..."
while ! ping -c1 google.com &>/dev/null; do
  sleep 1
done

# wait for apt availability
echo "waiting for apt to be available..."
while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
  sleep 1
done

# update ansible code
echo "downloading latest ansible code..."
if [ -d /usr/src/ansible-gpdpocket ]; then
  cd /usr/src/ansible-gpdpocket
  git pull -f
  git checkout ${BRANCH}
else
  git clone https://github.com/cawilliamson/ansible-gpdpocket.git /usr/src/ansible-gpdpocket
  cd /usr/src/ansible-gpdpocket
  git checkout ${BRANCH}
fi

# ensure /boot is mounted
echo "ensuring /boot is mounted..."
mount /boot >/dev/null 2>&1 || true

# run ansible scripts
echo "starting ansible playbook..."
ANSIBLE_NOCOWS=1 ansible-playbook site.yml -e "BRANCH=${BRANCH}"