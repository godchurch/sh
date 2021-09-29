#!/bin/sh
# https://help.ubuntu.com/community/Full_Disk_Encryption_Howto_2019

set -e

effectiveUserIdentity=`id -u`
test "$effectiveUserIdentity" -eq 0
mount | grep -q 'efivars'

export DEV="/dev/nvme0n1"
export DM="${DEV##*/}"
export DM="${DM}$(if printf '%s' "$DM" | grep -q 'nvme'; then printf 'p'; fi)"

sgdisk --zap-all "$DEV"
sgdisk --new=1:0:+768M --typecode=1:8301 --change-name=1:/boot \
       --new=2:0:+2M --typecode=2:ef02 --change-name=2:GRUB \
       --new=3:0:+128M --typecode=3:ef00 --change-name=3:EFI-SP \
       --new=5:0:0 --typecode=5:8301 --change-name=5:rootfs \
       "$DEV"
sgdisk --hybrid 1:2:3 "$DEV"

cryptsetup luksFormat --type=luks1 "${DEV}p1"
cryptsetup luksFormat "${DEV}p5"
cryptsetup open "${DEV}p1" "LUKS_BOOT"
cryptsetup open "${DEV}p5" "${DM}5_crypt"

mkfs.ext4 -L boot "/dev/mapper/LUKS_BOOT"
mkfs.vfat -F 16 -n EFI-SP "${DEV}p3"
mkfs.ext4 "/dev/mapper/${DM}5_crypt"

# run installer, manually configure partitions, setup user account...
echo "################################################"
echo "####            RUN INSTALLER               ####"
echo "################################################"
while [ ! -d /target/etc/default/grub.d ]; do sleep 1; done
echo "GRUB_ENABLE_CRYPTODISK=y" >> /target/etc/default/grub

exit 0

# post installation:
mount /dev/mapper/root /target
for n in proc sys dev etc/resolv.conf; do mount --rbind /$n /target/$n; done
chroot /target
mount -a
echo "KEYFILE_PATTERN=/etc/luks/*.keyfile" >> /etc/cryptsetup-initramfs/conf-hook
echo "UMASK=0077" >> /etc/initramfs-tools/initramfs.conf
mkdir /etc/luks
dd if=/dev/urandom of=/etc/luks/boot_os.keyfile bs=4096 count=1
chmod u=rx,go-rwx /etc/luks
chmod u=r,go-rwx /etc/luks/boot_os.keyfile
cryptsetup luksAddKey ${DEV}p1 /etc/luks/boot_os.keyfile
cryptsetup luksAddKey ${DEV}p5 /etc/luks/boot_os.keyfile
echo "LUKS_BOOT UUID=$(blkid -s UUID -o value ${DEV}p1) /etc/luks/boot_os.keyfile luks,discard" >> /etc/crypttab
echo "${DM}5_crypt UUID=$(blkid -s UUID -o value ${DEV}p5) /etc/luks/boot_os.keyfile luks,discard" >> /etc/crypttab
# cat /etc/crypttab
update-initramfs -u -k all
