# Set the keyboard layout to UK
loadkeys uk

# Make sure the data and time are correct, if not, exit
timedatectl
read -p "Is the time and date correct? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

