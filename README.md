# xWires Arch Install Scripts

## UEFI IS REQUIRED

## Overview

To use this script, download the `script_downloader,sh` file onto your Arch Linux live iso and run it, it will give you a menu of what installer to download. Once you have done that, run the installer and follow the instructions.

## Unattended install

(Currently this feature is only available on the Minimal installer)

### WARNING: Using the unattended installer will wipe the entire disk, causing irreversible damage to all files

To use the unattended installer, you must pass options after the name of the script. These are the options you can use:

- `--ukLayout` is used to specify whether to set the keyboard layout to UK (accepted values: true/false)
- `--syncTime` is used to tell the installer whether or not to sync the time with the hardware clock (accepted values: true/false)
- `--installDisk` specifies the disk to install Arch Linux to (accepted values: directory)
- `--rootSize` is the size of the root partition in GB, this value must end in "G", not "GB" (accepted values: \[number\]G)
- `--efiSize` is the size of the EFI partition, also in GB, must also end in "G" not "GB" (accepted values: \[number\]G)
- `--ukMirrors` if set to true, changes the mirror list to only include UK mirrors, if set to false, it will leave all mirrors in the list (accepted values: true/false)
- `--extraPackages` a space separated list of extra packages to install, surrounded by quote marks (accepted values: string)
- `--hostname` sets the hostname of the system (accepted values: string)
- `--rootPassword` sets the password for the root user, supports spaces, needs to be surrounded by quote marks (accepted values: string)
