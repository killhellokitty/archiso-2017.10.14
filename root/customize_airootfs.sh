#!/bin/bash

set -e -u

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

ln -sf /usr/share/zoneinfo/UTC /etc/localtime

setfont sun12x22

for i in {0..256}; do setterm -powerdown 0 >> /dev/tty$i; done; unset i;
for i in {0..256}; do setterm -blank 0 >> /dev/tty$i; done; unset i;

! id arch && useradd -m -p "" -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,ftp,games,sys,locate,input,video,lp,tty,wheel" -s /usr/bin/zsh arch

usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/

chmod 700 /root

#sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf
sed -i 's/Storage=volatile/#Storage=auto/' /etc/systemd/journald.conf

sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf

pacman-key --init && pacman-key --populate archlinux
cd /etc/pacman.d/gnupg/ && echo -e "\nkeyserver https://pgp.mit.edu\nkeyserver-options timeout=8s\nkeyserver hkp://zimmermann.mayfirst.org\nkeyserver-options timeout=8s\n" >> gpg.conf
cd /root/ && mkdir -p .gnupg && cd .gnupg && touch dirmngr_ldapservers.conf
dirmngr < /dev/null
# Key for ARCHZFS
set timeout 8s && pacman-key -r 5E1ABF240EE7A126 && echo | xxd
set timeout 5s && pacman-key --lsign-key 5E1ABF240EE7A126 && echo | xxd
pacman -Syy
# Key for Xyne-x86_64
set timeout 8s && pacman-key -r 8F173680 && echo | xxd
set timeout 5s && pacman-key --lsign-key 8F173680 && echo | xxd
pacman -Syy
# key for ArchStrike
#set timeout 8s && pacman-key -r 9D5F1C051D146843CDA4858BDE64825E7CBC0D51 && echo | xxd
#set timeout 5s && pacman-key --lsign-key 9D5F1C051D146843CDA4858BDE64825E7CBC0D51 && echo | xxd
#pacman -Syy
# ArchStrike keyring and Mirrorlist
#pacman -S archstrike-keyring
#pacman -S archstrike-mirrorlist
#pacman -Syy

#cp -r /etc/{mkinitcpio-custom-archiso.conf,mkinitcpio.conf,mkinitcpio-fallback.conf,mkinitcpio-zen.conf,mkinitcpio-zen-fallback.conf} /etc/

mkdir -p /etc/bash-completion.d/
mv /etc/_aurvote /etc/bash-completion.d/_aurvote

cp /etc/r8169.ko.gz /usr/lib/modules/4.13.5-1-zen/kernel/drivers/net/ethernet/realtek/r8169.ko.gz

cp -r /etc/iwlwifi-firmware/{iwlwifi-8000C-13.ucode,iwlwifi-8000C-16.ucode,iwlwifi-8000C-21.ucode,iwlwifi-8000C-22.ucode,iwlwifi-8000C-27.ucode,iwlwifi-8000C-28.ucode} /usr/lib/firmware/

touch /etc/modprobe.d/{blacklist-r8169-dkms.conf,blacklist-nouveau.conf,soundcard.conf,scsi-scan.conf,uvcvideo.conf}
echo -e "blacklist r8168\nblacklist r8169" > /etc/modprobe.d/blacklsit-r8169-dkms.conf
echo -e "blacklist nouveau\noptions nouveau modeset=0" > /etc/modprobe.d/blacklsit-nouveau.conf
echo -e '# Alsa Sound-Card modules' "\noptions snd-hda-intel index=0,-2\noptions snd-hda-intel\nsnd_hda_codec_realtek\nalias snd-card-0 snd-hda-intel\n" > /etc/modprobe.d/soundcard.conf
echo -e "\n\talias sound-service-0-0 snd-mixer-oss\n\talias sound-service-0-1 snd-seq-oss\n\talias sound-service-0-3 snd-pcm-oss\n\talias sound-service-0-8 snd-seq-oss\n\talias sound-service-0-12 snd-pcm-oss" >> /etc/modprobe.d/soundcard.conf
echo -e "options iwlwifi 11n_disable=8\noptions iwlwifi swcrypto=1\noptions iwlwifi led_mode=1" > /etc/modprobe.d/iwlwifi.conf
echo -e '# Enforce syschronous scsi scan, to prevent zfs driver loading before disks are available' "\noptions scsi_mod scan=sync" > /etc/modprobe.d/scsi-scan.conf
echo -e "options uvcvideo nodrop=1\noptions uvcvideo quirks=0x80\n#options ov51x-jpeg forceblock=1" > /etc/modprobe.d/uvcvideo.conf

systemctl enable pacman-init.service choose-mirror.service
systemctl enable nvidia-persistenced.service
systemctl enable reflector.service
systemctl set-default graphical.target
