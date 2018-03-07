#! /bin/bash

if [ $( whoami) != "root" ]; then
    echo "Sudo is requried to mount the iso";
    exit 1;
fi

if ! dpkg-query -W -f='${Status}' syslinux-utils | grep "ok installed"; then apt install syslinux-utils; fi

user=$(who | awk '{print $1}')

output_name="auto-ubuntu-16.04.4.iso"
iso_file="ubuntu-16.04.4-desktop-amd64.iso"

preseed_file="preseed.cfg"
isolinux_file="isolinux.cfg"
txt_file="txt.cfg"
grub="grub.cfg"

mkdir -p iso_new
mkdir -p iso_org

mount -o loop $iso_file iso_org > /dev/null 2>&1
cp -rT iso_org iso_new

cp -rT $preseed_file iso_new/$preseed_file
cp -rT $isolinux_file iso_new/isolinux/$isolinux_file
cp -rT $txt_file iso_new/isolinux/$txt_file
cp -rT $grub iso_new/boot/grub/$grub

mkisofs -D -r -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $output_name iso_new/. > /dev/null 2>&1
isohybrid $output_name
chown $user $output_name

umount iso_org
rm -rf iso_org
rm -rf iso_new
