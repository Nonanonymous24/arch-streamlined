# arch-streamlined
Arch Linux quick install script 

### Inspired from
[Ermanno Ferrari](https://gitlab.com/eflinux/arch-basic)

## What is this script?

This is a simple [Arch Linux](https://archlinux.org/) install script that provides a quick way to install the base system for Arch by assuming some common defaults and configuration options.
The aim is to provide a single script that would install the system in a single command for users who continuously install Arch for various purposes.

## What this script is not?

This script is not exactly designed for beginners and does not provide an interactive environment for the install.
For absolute beginners, try using the [archfi](https://github.com/MatMoul/archfi) script by [MatMoul](https://github.com/MatMoul) which provides an interactive installer and a bunch of different options to customize your install.

## Getting Started

This script is to be run after chrooting into the new environment.

### Preparing the environment

#### 1. Boot into the live environment
#### 2. Partition the disk(s) as needed
#### 3. Format the partitions
#### 4. Mount the partitions
#### 5. Run the following command to install required packages (use your preferred kernel and headers):
```
pacstrap /mnt base linux linux-headers nano wget
```
#### 6. Generate `fstab` using partition UUIDs:
```
genfstab -U /mnt >> /mnt/etc/fstab
```
#### 7. Enter the new environment:
```
arch-chroot /mnt
```
