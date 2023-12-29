#!/bin/bash

echo -e "\nxWires Arch Linux Installer with KDE\n"

# Set the keyboard layout to UK
function keyboardLayout {
    read -p "Set the keyboard layout to UK? (Y/N) " layout_change_confirm
    if [[ $layout_change_confirm == [yY] || $layout_change_confirm == [yY][eE][sS] ]]
    then
        loadkeys uk
    fi
}

# Make sure the data and time are correct, if not, synchronise it
function checkTime {
    timedatectl
    read -p "Is the time and date correct? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || { hwclock --systohc && echo -e "\nSynced clock"; }
}

# Setup disk partitions
function setupPartitions {
    read -p "Which disk will Arch Linux be installed to? " install_disk
    echo -e "\nIf you are using UEFI, you will need to make 2 partitions, a root partition (/) and an EFI System Partition (/boot)\n"
    read -n1 -s -r -p "Press any key to continue to cfdisk... " disk_continue
    cfdisk $install_disk
}

# Format partitions
function formatPartitions {
    read -p "The next part of the setup will format the root and EFI partitions, are you sure you want to continue? (Y/N) " disk_format_confirm && [[ $disk_format_confirm == [yY] || $disk_format_confirm == [yY][eE][sS] ]] || exit 1
    read -p "Where is your root partition located? (It will be formatted as ext4) " root_partition
    umount -q $root_partition
    mkfs.ext4 $root_partition
    read -p "Where is your EFI System Partition located? (It will be formatted as FAT32) " efi_partition
    umount -q $efi_partition
    mkfs.fat -F 32 $efi_partition
    mount --mkdir $root_partition /mnt
    mount --mkdir $efi_partition /mnt/boot
}

# Edit mirror list
function editMirrorList {
    read -p "Should the mirror list be changed to only include UK servers? (Y/N) " mirror_edit_confirm
    if [[ $mirror_edit_confirm == [yY] || $mirror_edit_confirm == [yY][eE][sS] ]]
    then
        curl https://raw.githubusercontent.com/TangledWiresYT/xwires_arch_install/main/uk_mirrorlist > /etc/pacman.d/mirrorlist
    fi
}

# Install packages
function installPackages {
    read -p "What additional packages do you want to install? (Separated by spaces, leave blank for no extra packages) " extra_packages
    pacstrap -K /mnt base linux linux-firmware vim wget grub efibootmgr networkmanager sudo xorg-server egl-wayland wayland firefox gnome gnome-tweaks $extra_packages
}

# Fstab
function fstab {
    genfstab -U /mnt >> /mnt/etc/fstab
}

# Configuration
function configure {
    echo -e "The system will now be configured with UK/GB based settings. You may change this after installation has completed."
    read -n1 -s -r -p "Press any key to continue... " config_continue
    echo -e "\nSetting timezone..."
    arch-chroot /mnt ln -sf /usr/share/zoneinfo/GB /etc/localtime
    arch-chroot /mnt hwclock --systohc
    echo -e "\nSetting locale..."
    arch-chroot /mnt wget -O /etc/locale.gen https://raw.githubusercontent.com/TangledWiresYT/xwires_arch_install/main/locale.gen
    arch-chroot /mnt locale-gen
    echo "LANG=en.GB.UTF-8" > /mnt/etc/locale.conf
    echo "KEYMAP=uk" > /mnt/etc/vconsole.conf
    read -p "What should the hostname be? " system_hostname
    echo $system_hostname > /mnt/etc/hostname
    echo "Set the root password"
    arch-chroot /mnt passwd
}

# Enable services
function enableServices {
    arch-chroot /mnt systemctl enable gdm
    arch-chroot /mnt systemctl enable NetworkManager
}

# GRUB install
function installGRUB {
    echo -e "\nInstalling GRUB"
    arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
}

function installComplete {
    read -n1 -s -r -p "Installation complete! Press any key to reboot..." reboot
    systemctl reboot
}

function fullInstall {
    keyboardLayout
    checkTime
    setupPartitions
    formatPartitions
    editMirrorList
    installPackages
    fstab
    configure
    enableServices
    installGRUB
    installComplete
}

if [ -n "$1" ]; then
	if ! type "$1" &> /dev/null; then
		echo "The function $1 does not exist!"
		exit 1
	fi
	$1
	exit
fi

fullInstall