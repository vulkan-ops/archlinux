#!/usr/bin/env bash
# github.com/mamutal91

ln -s /hostlvm /run/lvm

echo "Config pacman"
sed -i "/\[multilib\]/,/Include/"'s/^#//' /mnt/etc/pacman.conf
sed -i "s/#Color/Color/g" /mnt/etc/pacman.conf
sed -i "s/#TotalDownload/TotalDownload/g" /mnt/etc/pacman.conf

echo "Set locale and zone"
sed -i "s/#pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/g" /etc/locale.gen
sed -i "s/#pt_BR ISO-8859-1/pt_BR ISO-8859-1/g" /etc/locale.gen
locale-gen
echo LANG=pt_BR.UTF-8 > /etc/locale.conf
echo aspire > /etc/hostname
sudo ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

echo "Config mkinitpcio"
sed -i "s/block/block encrypt lvm2/g" /etc/mkinitcpio.conf

mkinitcpio -P

echo "Config sudoers"
sed -i "s/root ALL=(ALL) ALL/root ALL=(ALL) NOPASSWD: ALL\nmamutal91 ALL=(ALL) NOPASSWD:ALL/g" /etc/sudoers

# systemd
sed -i "s/#HandleLidSwitch=ignore/HandleLidSwitch=ignore/g" /etc/systemd/logind.conf

echo "Config grub"
UUID=$(blkid /dev/sda2 | awk -F '"' '{print $2}')
sed -i -e 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet splash acpi_backlight=vendor acpi_osi=Linux"/g' /etc/default/grub
sed -i -e 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cryptdevice=UUID='$UUID':lvm"/g' /etc/default/grub
sed -i "s/#GRUB_ENABLE_CRYPTODISK=y/GRUB_ENABLE_CRYPTODISK=y/g" /etc/default/grub
sed -i "s/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g" /etc/default/grub

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg

echo "Add my user"
useradd -m -G wheel -s /bin/bash mamutal91
mkdir -p /home/mamutal91
passwd mamutal91
passwd root

git clone https://github.com/mamutal91/dotfiles /home/mamutal91/.dotfiles

systemctl enable NetworkManager
systemctl enable dhcpcd
systemctl disable iwd