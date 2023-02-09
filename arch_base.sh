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
BLOCK_DEVICE="/dev/sda"     ### Do not set this variable equal to a partition, rather the drive itself.

CPU="intel"         ### OPTIONS (intel, amd, none) ##Installs intel by default if not set to "amd"

GPU="qxl"           ### OPTIONS (qxl, intel, amd, nvidia, none)
                    ### do not use capital letters
                    ### If on a VM, use "qxl" 
                    ### Installs none by default if not set to nvidia, intel, qxl, or amd

KERNEL="linux"      ### OPTIONS (linux, linux-lts, linux-zen, linux-hardened) 
                    ### Installs the vanilla kernel if not explicitly specified


### SCRIPT START

/bin/echo -e "\e[1;32mStarting install...\e[0m"

# Syncing time server
/bin/echo -e "\e[1;32mGetting time from ntp server...\e[0m"
timedatectl set-ntp true

# Installing the base system and kernel
/bin/echo -e "\e[1;32mInstalling base system and $KERNEL kernel...\e[0m"

if [ $KERNEL == "linux-lts" ]; then
    pacstrap /mnt base linux-lts linux-lts-headers
elif [ $KERNEL == "linux-zen" ]; then
    pacstrap /mnt base linux-zen linux-zen-headers
elif [ $KERNEL == "linux-hardened" ]; then
    pacstrap /mnt base linux-hardened linux-hardened-headers
else
    pacstrap /mnt base linux linux-headers
fi

sleep 10

/bin/echo -e "\e[1;32mInstalled base system and $KERNEL kernel.\e[0m"

# Installing firmware for processor
/bin/echo -e "\e[1;32mInstalling firmware for $CPU processor...\e[0m"
if [ $CPU == "amd" ]; then
    pacstrap /mnt amd-ucode
elif [ $CPU == "intel" ]; then
    pacstrap /mnt intel-ucode
else
    /bin/echo -e "\e[1;32mNot installing cpu firmware.\e[0m"
fi

sleep 5 

/bin/echo -e "\e[1;32mInstalled firmware for $CPU processor.\e[0m"

# Installing more packages
/bin/echo -e "\e[1;32mInstalling more packages...\e[0m"
pacstrap /mnt nano vim reflector

sleep 5
# Generating fstab file
/bin/echo -e "\e[1;32mGenerating the fstab file...\e[0m"
genfstab -U /mnt >> /mnt/etc/fstab
/bin/echo -e "\e[1;32mGenerated the fstab file as follows:\e[0m"
cat /mnt/etc/fstab

/bin/echo -e "\e[1;32mIf the file looks incorrect to you, stop the installation right here and fix the problem. You'll be chrooted in 20 seconds.\e[0m"
sleep 20

/bin/echo -e "\e[1;32mChrooting into the new environment...\e[0m"
arch-chroot /mnt /bin/bash << EOF

# Set the timezone
/bin/echo -e "\e[1;32mSetting the timezone to $TIMEZONE...\e[0m"
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
/bin/echo -e "\e[1;32mTimezone set to $TIMEZONE.\e[0m"

# Sync hardware clock to system clock
/bin/echo -e "\e[1;32mSyncing hardware clock to system clock...\e[0m"
hwclock --systohc

# Generate locales and update locale.conf
/bin/echo -e "\e[1;32mGenerating en_US.UTF-8 locale...\e[0m"
sed -i '171s/.//' /etc/locale.gen
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
pacman -S --needed --noconfirm grub efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools base-devel linux-firmware xdg-user-dirs xdg-utils inetutils dnsutils bluez bluez-utils alsa-utils pulseaudio bash-completion openssh rsync bridge-utils dnsmasq ipset git

## Install graphic drivers
/bin/echo -e "\e[1;32mInstalling graphic drivers for $GPU card...\e[0m"

if [ $GPU == "amd" ]; then
    pacman -S --needed --noconfirm xf86-video-amdgpu
elif [ $GPU == "intel" ]; then
    pacman -S --needed --noconfirm xf86-video-intel
elif [ $GPU == "nvidia" ]; then
    pacman -S --needed --noconfirm nvidia nvidia-utils
elif [ $GPU == "qxl" ]; then
    pacman -S --needed --noconfirm xf86-video-qxl
else
    /bin/echo -e "\e[1;32mNot installing graphic drivers\e[0m"
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

/bin/echo -e "\e[1;32mThe script should detect Windows installation in case of dual-boot, if mounted correctly.\e[0m"
/bin/echo -e "\e[1;32mIn case you don't see a Windows image in the above output, stop the script and figure out the problem. The script will continue in 10 seconds.\e[0m"
sleep 10

# Enable services
/bin/echo -e "\e[1;32mEnabling required services...\e[0m"
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable sshd

# Create user (change username and password)
/bin/echo -e "\e[1;32mCreating new user with username $USERNAME...\e[0m"
useradd -m $USERNAME
/bin/echo -e "\e[1;32mSetting password for $USERNAME to $PASSWORD...\e[0m"
echo $USERNAME:$PASSWORD | chpasswd
# add user to sudoers file
/bin/echo -e "\e[1;32mAdding user to sudoers file...\e[0m"
echo "$USERNAME ALL=(ALL) ALL" >> /etc/sudoers.d/$USERNAME

### SCRIPT END

EOF

#Unmount the partitions
/bin/echo -e "\e[1;32mUnmounting partitions...\e[0m"
umount -R /mnt

/bin/echo -e "\e[1;32mInstall complete!\e[0m"
/bin/echo -e "\e[1;32mRoot password is set to $PASSWORD_ROOT.\e[0m"
/bin/echo -e "\e[1;32mLog in with $USERNAME and password $PASSWORD.\e[0m"

/bin/echo -e "\e[1;32mIf you're using VirtualBox, type Ctrl+c to stop the script here and shutdown the system.\e[0m"
/bin/echo -e "\e[1;32mSystem will reboot in 10 seconds.\e[0m"
sleep 10
reboot
