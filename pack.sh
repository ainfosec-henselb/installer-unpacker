#!/bin/bash

    sudo umount dom0/mount
    set -e
    rm -f control.tar.bz2 control.tar dom0-rootfs.i686.xc.ext3 dom0-rootfs.i686.xc.ext3.gz
    ( cd installer && tar -cvf ../control.tar ./* )
    bzip2 control.tar
    cp control.tar.bz2 iso_tmp/packages.main/
    sync
    cp dom0/dom0-rootfs.i686.xc.ext3 .
    gzip dom0-rootfs.i686.xc.ext3
    cp dom0-rootfs.i686.xc.ext3.gz iso_tmp/packages.main
    CSIZE=$(wc -c control.tar.bz2 | awk '{print $1}')
    CSHA=$(sha256sum control.tar.bz2 | awk '{print $1}')
    DSIZE=$(wc -c dom0-rootfs.i686.xc.ext3.gz | awk '{print $1}')
    DSHA=$(sha256sum dom0-rootfs.i686.xc.ext3.gz | awk '{print $1}')
    echo -e "control $CSIZE $CSHA tarbz2 required control.tar.bz2 /\ndom0 $DSIZE $DSHA ext3gz required dom0-rootfs.i686.xc.ext3.gz /" | cat - manifest > iso_tmp/packages.main/XC-PACKAGES
    EFIBOOTIMG="iso_tmp/isolinux/efiboot.img"
    dd if=/dev/zero bs=1M count=5 of=${EFIBOOTIMG}
    /sbin/mkfs.fat ${EFIBOOTIMG}
    mkdir -p efi_tmp
    fusefat -o rw+ ${EFIBOOTIMG} efi_tmp
    mkdir -p efi_tmp/EFI/BOOT
    cp -f raw/grubx64.efi efi_tmp/EFI/BOOT/BOOTX64.EFI
    sync
    fusermount -u efi_tmp
    rm -rf efi_tmp

    echo "Creating installer.iso..."
    xorriso -as mkisofs \
                -o "installer.repacked" \
                -isohybrid-mbr "raw/isohdpfx.bin" \
                -c "isolinux/boot.cat" \
                -b "isolinux/isolinux.bin" \
                -no-emul-boot \
                -boot-load-size 4 \
                -boot-info-table \
                -eltorito-alt-boot \
                -e "isolinux/efiboot.img" \
                -no-emul-boot \
                -isohybrid-gpt-basdat \
                -r \
                -J \
                -l \
                -V "OpenXT-${VERSION}" \
                -f \
                -quiet \
                "iso_tmp"
echo "Done"

