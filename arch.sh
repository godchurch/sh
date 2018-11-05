#!/bin/sh

set -e

timedatectl set-ntp true
parted -s /dev/sda mklabel msdos mkpart primary ext4 1MiB 100% set 1 boot on
mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt
pacstrap /mnt base grub
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt ln -sf /usr/share/zoneinfo/UTC /etc/localtime
arch-chroot /mnt hwclock --systohc
cp /etc/locale.gen /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
printf "%s\n" "LANG=en_US.UTF-8" >> /mnt/etc/locale.conf
printf "%s\n" "arch-linux" >> /mnt/etc/hostname
printf "%s\t%s\n"     "127.0.0.1" "localhost"                           >> /mnt/etc/hosts
printf "%s\t\t%s\n"   "::1"       "localhost"                           >> /mnt/etc/hosts
printf "%s\t%s\t%s\n" "127.0.1.1" "arch-linux.localdomain" "arch-linux" >> /mnt/etc/hosts
arch-chroot /mnt systemctl enable dhcpcd.service
arch-chroot /mnt mkinitcpio -p linux
arch-chroot /mnt passwd
arch-chroot /mnt grub-install --target=i386-pc /dev/sda
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
