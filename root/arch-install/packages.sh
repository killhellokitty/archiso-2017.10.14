#!/bin/bash

mkdir -p /mnt/var/cache/pacman/pkg
cp -r  ~/packages/* /mnt/var/cache/pacman/pkg

rm -rf /var/cache/pacman/pkg
ln -s /mnt/var/cache/pacman/pkg /var/cache/pacman/pkg

time cp -ax / /mnt
cp -vaT /run/archiso/bootmnt/arch/boot/${uname -m}/vmlinuz  /mnt/boot/vmlinuz-linux-zen

cp -vraT /etc/modprobe.d /mnt/etc/modprobe.d
cp -vraT /etc/bash-completion.d /mnt/etc/bash-completion.d

cp -vraT /etc/writehostid /mnt/etc/writehostid && cd /mnt/etc/writehostid && ./write_host_id.sh

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime

setfont sun12x20

for i in {0..256}; do setterm -powerdown 0 >> /dev/tty$1; done; unset i; &&
for i in {0..256}; do setterm -blank 0 >> /dev/tty$1; done; unset i;

cp /etc/pacman.conf /mnt/etc/pacman.conf
pacman-key --init && pacman-key --populate archlinux
cd /etc/pacman.d/gnupg/gpg.conf && echo -e "\nkeyserver hkp://pool.sks-keyservers.net\nkeyserver-options timeout=8s\nkeyserver hkp://zimmermann.mayfirst.org\nkeyserver-options timeout=8s\n"
cd /root/ && mkdir -p .gnupg && cd .gnupg && touch dirmngr_ldapservers.conf
# Key for ARCHZFS
set timeout 5s && pacman-key -r 5E1ABF240EE7A126 && echo | xxd
set timeout 3s && pacman-key --lsign-key 5E1ABF240EE7A126 && echo | xxd
# Key for Xyne-x86_64
set timeout 5s && pacman-key -r 8F173680 && echo | xxd
set timeout 3s && pacman-key --lsign-key 8F173680 && echo | xxd
pacman -Syy

cp -vraT /etc/mkinitcpio.d/ /mnt/etc/mkinitcpio.d/
cp -vraT /etc/{mkinitcpio-custom-archiso.conf,mkinitcpio.conf,mkinitcpio-fallback.conf,mkinitcpio-zen.conf,mkinitcpio-zen-fallback.conf} /mnt/etc/

cp -vraT /usr/lib/modules/4.13.5-1-zen/kernel/drivers/net/ethernet/realtek/r8169.ko.gz /mnt/usr/lib/modules/4.13.5-1-zen/kernel/drivers/net/ethernet/realtek/r8169.ko.gz

cp -vraT /usr/lib/firmware/{iwlwifi-8000C-13.ucode,iwlwifi-8000C-16.ucode,iwlwifi-8000C-21.ucode,iwlwifi-8000C-22.ucode,iwlwifi-8000C-27.ucode,iwlwifi-8000C-28.ucode} /mnt/usr/lib/firmware/

systemctl enable nvidia-persistenced.service
systemctl enable reflector.service
systemctl enable gdm.service
