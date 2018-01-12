#!/bin/bash

sudo umount dom0/mount
sync

set -e

sudo rm -rf iso_tmp/ installer/ dom0/
mkdir -p iso_tmp/
mkdir -p installer/
mkdir -p dom0/mount
7z -oiso_tmp x installer.iso
( cd installer && tar xvf ../iso_tmp/packages.main/control.tar.bz2 . )
cp iso_tmp/packages.main/dom0-rootfs.i686.xc.ext3.gz dom0/
( cd dom0 && gunzip dom0-rootfs.i686.xc.ext3.gz )
sudo mount dom0/dom0-rootfs.i686.xc.ext3 dom0/mount

tail -n +3 iso_tmp/packages.main/XC-PACKAGES > manifest

