#!/bin/bash -a

cat <<EOF
make sure that an SD card with 2 empty partitions is in the Linux HOST
- if ok, press Enter
- if not, press ^C and follow instructions in Prepare-SD-Card.txt
EOF
read x

mkdir -p ~/el/firmware
cd ~/el/firmware

## step #1: copy u-boot.bin
	sudo cp ~/el/u-boot/u-boot.bin /mnt/boot 

## step #2: download latest RPi /boot directory
	svn checkout https://github.com/raspberrypi/firmware/trunk/boot
  sudo cp boot/bootcode.bin /mnt/boot/
  sudo cp boot/start4.elf /mnt/boot/

## step #3: create config.txt to notify RPi bootloader to load U-Boot.
cat <<-EOF > config.txt
	enable_uart=1
	arm_64bit=1
	kernel=u-boot.bin
EOF

sudo cp config.txt /mnt/boot/
