# Set the keyboard layout to UK
loadkeys uk

# Make sure the data and time are correct, if not, exit
timedatectl
read -p "Is the time and date correct? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

# Setup disk partitions
read -p "Which disk will Arch Linux be installed to? " install_disk
echo "If you are using UEFI, you will need to make 2 partitions, a root partition (/) and an EFI System Partition (/boot)"
read -n1 -s -r -p "Press any key to continue... " disk_continue
cfdisk $install_disk
