#!/bin/bash

echo -e "\nxWires Minimal Arch Linux Installer\n"

OPTIONS=$(getopt -o "" --long ukLayout:,syncTime:,installDisk:,rootSize:,efiSize:,ukMirrors:,extraPackages: -n '$0' -- "$@")

if [ $? -ne 0 ]; then
  echo "Error: Invalid options. Exiting..." >&2
  exit 1
fi

eval set -- "$OPTIONS"

# Initialize variables
ukLayout=
syncTime=
installDisk=
rootSize=
efiSize=
ukMirrors=
extraPackages=

# Process options
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ukLayout)
      ukLayout="$2"
      shift 2
      ;;
    --syncTime)
      syncTime="$2"
      shift 2
      ;;
    --installDisk)
      installDisk="$2"
      shift 2
      ;;
    --rootSize)
      rootSize="$2"
      shift 2
      ;;
    --efiSize)
      efiSize="$2"
      shift 2
      ;;
    --ukMirrors)
      ukMirrors="$2"
      shift 2
      ;;
    --extraPackages)
      shift
      extraPackages="$1"
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Internal error!"
      exit 1
      ;;
  esac
done

# Set the keyboard layout to UK
function keyboardLayout {
    if [ -n "$1" ]; then
        if [ $1 == "true" ]; then
            echo -e "Setting UK keyboard layout"
            loadkeys uk
        elif [ $1 == "false" ]; then
            echo -e "Skipping UK keyboard layout"
        else
            echo -e "Unknown option $1, exiting"
            exit 1
        fi
    else
        read -p "Set the keyboard layout to UK? (Y/N) " layout_change_confirm
        if [[ $layout_change_confirm == [yY] || $layout_change_confirm == [yY][eE][sS] ]]
        then
            loadkeys uk
        fi
    fi
}

# Make sure the data and time are correct, if not, synchronise it
function checkTime {
    if [ -n "$1" ]; then
        if [ $1 == "true" ]; then
            echo -e "Syncing clock"
            loadkeys uk
        elif [ $1 == "false" ]; then
            echo -e "Skipping clock sync"
        else
            echo -e "Unknown option $1, exiting"
            exit 1
        fi
    else
        timedatectl
        read -p "Is the time and date correct? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || { hwclock --systohc && echo -e "\nSynced clock"; }  
    fi
}

# Setup disk partitions
function setupPartitions {
    if [ -n "$1" ]; then
        # sfdisk input file
        sfdisk_input=$(cat <<EOL
label: gpt
label-id: 1F3113FA-7F1D-4CCD-98C5-C18D1A9ACF18
device: $1
unit: sectors

: size=$rootSize, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4
: size=$efiSize, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, attrs="LegacyBIOSBootable"
EOL
)

        # Create partitions
        echo "$sfdisk_input" | sfdisk --no-reread "$1"
    else
        read -p "Which disk will Arch Linux be installed to? " install_disk
        echo -e "\nIf you are using UEFI, you will need to make 2 partitions, a root partition (/) and an EFI System Partition (/boot)\n"
        read -n1 -s -r -p "Press any key to continue to cfdisk... " disk_continue
        cfdisk $install_disk
    fi
}

# Format partitions
function formatPartitions {
    if [ -n "$1" ] && [ -n "$2" ]; then
        umount -q $1
        mkfs.ext4 $1
        umount -q $2
        mkfs.fat -F 32 $2
        mount --mkdir $1 /mnt
        mount --mkdir $2 /mnt/boot
    else
        read -p "The next part of the setup will format the root and EFI partitions, are you sure you want to continue? (Y/N) " disk_format_confirm && [[ $disk_format_confirm == [yY] || $disk_format_confirm == [yY][eE][sS] ]] || exit 1
        read -p "Where is your root partition located? (It will be formatted as ext4) " root_partition
        umount -q $root_partition
        mkfs.ext4 $root_partition
        read -p "Where is your EFI System Partition located? (It will be formatted as FAT32) " efi_partition
        umount -q $efi_partition
        mkfs.fat -F 32 $efi_partition
        mount --mkdir $root_partition /mnt
        mount --mkdir $efi_partition /mnt/boot
    fi
}

# Edit mirror list
function editMirrorList {
    if [ -n "$1" ]; then
        if [ $1 == "true" ]; then
            echo -e "Setting UK mirrors only"
            loadkeys uk
        elif [ $1 == "false" ]; then
            echo -e "Keeping default mirrors"
        else
            echo -e "Unknown option $1, exiting"
            exit 1
        fi
    else
        read -p "Should the mirror list be changed to only include UK servers? (Y/N) " mirror_edit_confirm
        if [[ $mirror_edit_confirm == [yY] || $mirror_edit_confirm == [yY][eE][sS] ]]
        then
            curl https://raw.githubusercontent.com/TangledWiresYT/xwires_arch_install/main/uk_mirrorlist > /etc/pacman.d/mirrorlist
        fi
    fi
}

# Install packages
function installPackages {
    if [ -n "$1" ]; then
        extra_packages=$1
        if [ $1 == "none" ]; then
            extra_packages=""
        fi
        pacstrap -K /mnt base linux linux-firmware vim wget grub efibootmgr networkmanager sudo $extra_packages
    else
        read -p "What additional packages do you want to install? (Separated by spaces, leave blank for no extra packages) " extra_packages
        pacstrap -K /mnt base linux linux-firmware vim wget grub efibootmgr networkmanager sudo $extra_packages
    fi
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
    keyboardLayout $ukLayout
    checkTime $syncTime
    setupPartitions $installDisk
    formatPartitions ${installDisk}1 ${installDisk}2
    editMirrorList $ukMirrors
    installPackages $extraPackages
    fstab
    configure
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