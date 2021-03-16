# arch-streamlined
Arch Linux quick install scripts for base and DEs

### Inspired from
[Ermanno Ferrari](https://gitlab.com/eflinux/arch-basic)

## What is this script?

This is a simple [Arch Linux](https://archlinux.org/) install script that provides a quick way to install the base system for Arch by assuming some common defaults and configuration options.
The aim is to provide a single script that would install the system in a single command for users who continuously install Arch for various purposes.

## What this script is not?

This script is not exactly designed for beginners and does not provide an interactive environment for the install.
For absolute beginners, try using the [archfi](https://github.com/MatMoul/archfi) script by [MatMoul](https://github.com/MatMoul) which provides an interactive installer and a bunch of different options to customize your install.

## Contents

1. Arch Linux base install script
2. Desktop Environment install scripts for:
    - KDE Plasma
    - Gnome

## Getting Started

### Pre-install tasks:

1. Boot into the live environment
2. Partition the disks
3. Format and mount the partitions

### Defaults in the script:

#### Defaults that can be changed using variables:
- Root password: password
- Username: username
- User password: password
- Timezone: Asia/Kolkata
- Hostname: Arch
- Block device name: `/dev/sda`
- Firmware Interface(for GRUB bootloader): BIOS/MBR
- CPU: Intel
- GPU: qxl
- Kernel: `linux`

#### Defaults that cannot be changed using variables:
- `fstab` file is generated with the UUIDs of partitions
- Locale: en_US.UTF-8 UTF-8
- KEYMAP: default
- Bootloader: GRUB2
- User created is added to sudoers file

## Install instructions:

#### Step 1:

To get started right away
```
wget https://raw.githubusercontent.com/Nonanonymous24/arch-streamlined/main/arch_base.sh
```
Optionally, you can clone the repo with
```
git clone https://github.com/Nonanonymous24/arch-streamlined.git
```
#### Step 2:

Edit the file `arch_base.sh` using `vim` which is provided with the ISO by default
```
vim arch_base.sh
```
Make necessary changes to the **VARIABLES** section. You would want to change your username and password at the least. Make sure to check if the rest of the defaults agree with your system.

#### Step 3:

Make the file executable
```
chmod +x arch_base.sh
```
#### Step 4:

Now finally, run the script
```
./arch_base.sh
```
#### Step 5:

After the system reboots, login with the newly created user.

Choose any particular desktop install script. 
For example, to install minimal KDE Plasma:
```
wget https://github.com/Nonanonymous24/arch-streamlined/blob/main/kde_minimal.sh
```
Follow the same process as shown above with the base intall script.
