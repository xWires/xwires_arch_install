# Set the keyboard layout to UK
read -p "Set the keyboard layout to UK? (Y/N) " layout_change_confirm
if [[ $layout_change_confirm == [yY] || $layout_change_confirm == [yY][eE][sS] ]]
then
    loadkeys uk
fi

# Make sure the data and time are correct, if not, exit
timedatectl
read -p "Is the time and date correct? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

# Setup disk partitions
read -p "Which disk will Arch Linux be installed to? " install_disk
echo -e "\nIf you are using UEFI, you will need to make 2 partitions, a root partition (/) and an EFI System Partition (/boot)\n"
read -n1 -s -r -p "Press any key to continue to cfdisk... " disk_continue
cfdisk $install_disk

# Format partitions
read -p "The next part of the setup will format the root and EFI partitions, are you sure you want to continue? (Y/N)" disk_format_confirm && [[ $disk_format_confirm == [yY] || $disk_format_confirm == [yY][eE][sS] ]] || exit 1
read -p "Where is your root partition located? (It will be formatted as ext4) " root_partition
mkfs.ext4 $root_partition
read -p "Where is your EFI System Partition located? (It will be formatted as FAT32) " efi_partition
mkfs.fat -F 32 $efi_partition

# Mount partitions
mount --mkdir $root_partition /mnt
mount --mkdir $efi_partition /mnt/boot

# Edit mirror list
read -p "Should the mirror list be changed to only include UK servers? (Y/N) " mirror_edit_confirm
if [[ $mirror_edit_confirm == [yY] || $mirror_edit_confirm == [yY][eE][sS] ]]
then
    curl https://raw.githubusercontent.com/TangledWiresYT/xwires_arch_install/main/uk_mirrorlist > /etc/pacman.d/mirrorlist
fi

# Install packages
pacstrap -K /mnt base linux linux-firmware firefox vim

# Fstab
genfstab -U /mnt >> /mnt/etc/fstab