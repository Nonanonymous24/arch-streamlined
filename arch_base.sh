#!/bin/bash

#### SET YOUR VARIABLES HERE
#### DO NOT USE SPACES IN VARIABLE NAMES

TIMEZONE="Asia/Kolkata"
HOSTNAME="Arch"
PASSWORD_ROOT="password"      ### Set root password here

# User details
USERNAME="username"         ### Set username with standard *NIX naming rules
                            ### The script will allow bad names but
                            ### it is not advised to use them.
PASSWORD="password"         ### Set password for the user

# For GRUB bootloader (VERY IMPORTANT)
FIRMWARE="BIOS/MBR"         ### Takes values "BIOS/MBR" and "UEFI/GPT"

### IF USING BIOS/MBR, set name of block device here (For eg. /dev/sda, /dev/vda)
BLOCK_DEVICE="/dev/sda"

GPU="qxl"           ### OPTIONS (qxl, intel, amd, nvidia)
                    ### do not use capital letters
                    ### If on a VM, use "qxl"

### SCRIPT START

/bin/echo -e "\e[1;32mStarting install...\e[0m"

# Set the timezone
/bin/echo -e "\e[1;32mSetting the timezone to $TIMEZONE...\e[0m"
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
/bin/echo -e "\e[1;32mTimezone set to $TIMEZONE.\e[0m"

# Sync hardware clock to system clock
/bin/echo -e "\e[1;32mSyncing hardware clock to system clock...\e[0m"
hwclock --systohc

# Generate locales and update locale.conf
/bin/echo -e "\e[1;32mGenerating en_US.UTF-8 locale...\e[0m"
sed -i '177s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Set system hostname(Arch) and edit hosts file
/bin/echo -e "\e[1;32mSetting system hostname to $HOSTNAME...\e[0m"
echo "$HOSTNAME" >> /etc/hostname
/bin/echo -e "\e[1;32mEditing hosts file...\e[0m"
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

# Set root password (change password)
/bin/echo -e "\e[1;32mSetting root password to $PASSWORD_ROOT...\e[0m"
echo root:$PASSWORD_ROOT | chpasswd
/bin/echo -e "\e[1;32mRoot password set.\e[0m"

# Install required packages (the list is extensive so make sure to remove what you don't need)
/bin/echo -e "\e[1;32mInstalling required packages...\e[0m"
pacman -S --needed --noconfirm grub efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools reflector base-devel linux-firmware xdg-user-dirs xdg-utils inetutils dnsutils bluez bluez-utils alsa-utils pulseaudio bash-completion openssh rsync virt-manager qemu qemu-arch-extra ovmf bridge-utils dnsmasq vde2 openbsd-netcat ebtables iptables ipset git

## Install graphic drivers
/bin/echo -e "\e[1;32mInstalling graphic drivers...\e[0m"

if [ $GPU == "qxl" ]; then
    pacman -S --needed --noconfirm xf86-video-qxl
elif [ $GPU == "amd" ]; then
    pacman -S --needed --noconfirm xf86-video-amdgpu
elif [ $GPU == "intel" ]; then
    pacman -S --needed --noconfirm xf86-video-intel
else
    pacman -S --needed --noconfirm nvidia nvidia-utils
fi

## Install grub bootloader
/bin/echo -e "\e[1;32mInstalling GRUB Bootloader...\e[0m"
if [ $FIRMWARE == "BIOS/MBR" ]; then
    grub-install --target=i386-pc $BLOCK_DEVICE
else
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
fi

## Make grub configuration
grub-mkconfig -o /boot/grub/grub.cfg

# Enable services
/bin/echo -e "\e[1;32mEnabling required services...\e[0m"
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable sshd
systemctl enable libvirtd

# Create user (change username and password)
/bin/echo -e "\e[1;32mCreating new user with username $USERNAME...\e[0m"
useradd -m --badnames $USERNAME
/bin/echo -e "\e[1;32mSetting password for $USERNAME to $PASSWORD...\e[0m"
echo $USERNAME:$PASSWORD | chpasswd
# for KVM
usermod -aG libvirt $USERNAME
# add user to sudoers file
/bin/echo -e "\e[1;32mAdding user to sudoers file...\e[0m"
echo "$USERNAME ALL=(ALL) ALL" >> /etc/sudoers.d/$USERNAME


/bin/echo -e "\e[1;32mInstall complete!\e[0m"
/bin/echo -e "\e[1;32mRoot password is set to $PASSWORD_ROOT.\e[0m"
/bin/echo -e "\e[1;32mLog in with $USERNAME and password $PASSWORD.\e[0m"
/bin/echo -e "\e[1;32mExit the system, unmount the partitions and reboot.\e[0m"

### SCRIPT END

