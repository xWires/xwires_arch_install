echo -e "\nWhich installer do you want to download?"
echo -e "\n1. Minimal"
echo "2. KDE Plasma"

read -p "Enter a number between 1 and 2: " installer_number

if [ $installer_number == 1 ]
then
    if [ -f minimal_installer.sh ]
    then
        echo "minimal_installer.sh already exists."
        exit 1
    else
        curl https://raw.githubusercontent.com/TangledWiresYT/xwires_arch_install/main/arch_install_minimal.sh > minimal_installer.sh
        chmod +x minimal_installer.sh
        echo -e "\nDownloaded installer to minimal_installer.sh"
    fi
elif [ $installer_number == 2 ]
then
    if [ -f kde_arch_installer.sh ]
    then
        echo "kde_arch_installer.sh already exists."
        exit 1
    else
        curl https://raw.githubusercontent.com/TangledWiresYT/xwires_arch_install/main/arch_install_kde.sh > kde_arch_installer.sh
        chmod +x kde_arch_installer.sh
        echo -e "\nDownloaded installer to kde_arch_installer.sh"
    fi
else
    echo -e "\nThat wasn't one of the options."
    exit 1
fi