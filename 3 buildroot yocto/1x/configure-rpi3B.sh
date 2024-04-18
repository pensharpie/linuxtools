#!/bin/bash -a

# Step #1: see if build root is already installed.
cd ~/el
[ -d buildroot ] && { mv buildroot buildroot.rpi3B; }
[ -d buildroot.rpi3B ] || { echo "no buildroot installed. pls install from example 1 in ch3."; exit 1; }

# Step #2: ok. it is there; list configs and set the defconfig
cd buildroot.rpi3B
make list-defconfigs | grep raspberrypi3
make raspberrypi3_64_defconfig

# Step #3: now make
# needs perl-ExtUtils-MakeMaker
# yum -y install perl-ExtUtils-MakeMaker
# or
# apt-get -y install perl-ExtUtils-MakeMaker
time make
  
# Step #4:
# when the build finishes the image is written to a file named
# output/images/sdcard.img

# there are two other important files:
# post-image.sh, and
# genimage-raspberrypi4-64.cfg 
# it is a script and a config file - both used to write the image file
# and are located in the board/raspberrypi/ directory.

# e.g. to write the sdcard.img to an microSD card and boot it on 
# the raspberrypi follow these steps.
# 1. insert the microSD card into the host machine card reader
# 2. Launch Etcher 
# 3. Click on Flash from File on Etcher.
# 4. Locate and Select the sdcard.img file built for the RPi.
# 5. Click Select target on Etcher.
# 6. Select the microSD card inserted in Step #1.
# 7. Click Flash on Etcher to write the image.
# 8. Eject the microSD card once Etcher is done.
# 9. Insert the microSD card into the RPi4.
#10. Apply power and start the RPi4.
##
# Confirm that the Pi4 booted successfully. 
# Plug it into the network and the network activity lights should blink.
# You can add an ssh server such as dropbear or openssh 
# to the buildroot image configuration.
