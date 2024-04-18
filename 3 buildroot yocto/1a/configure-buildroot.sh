#!/bin/bash -a

CWD="`pwd`"
set -e

RPI=${1:-"raspberrypi4"}

filewatchCP()
{
  IFN="$1"
  RFN="$2"
  SLP="$3"

  RDN="`dirname $RFN`"
  ( while [ ! -e ${RDN} ]
    do  
      sleep $SLP
    done
    sync;
    sleep 1
    # mv ${RFN} ${RFN}.orig 2>/dev/null
    cp ${IFN} ${RFN}; 
  )&
}  


# Step #1: see if build root is already installed.
cd ~/el
# [ -d buildroot ] && { mv buildroot buildroot.rpi4; }
# [ -d buildroot.rpi4 ] || { echo "no buildroot installed. pls install from example 1 in ch4."; exit 1; }
[ -d buildroot ] || { echo "no buildroot installed. pls install from example 1 in ch4."; exit 1; }

# Step #2: ok. it is there; list configs and set the defconfig
#cd buildroot.rpi4
cd buildroot
# { egrep -i -q ubuntu /proc/version; } && { libtoolize; }
# make list-defconfigs | grep raspberrypi4
make list-defconfigs | grep ${RPI}
make ${RPI}_64_defconfig

# Step #3: now make
cat <<EOF


# perl needs perl-ExtUtils-MakeMaker
yum -y install perl-ExtUtils-MakeMaker perl
# or
apt-get -y install perl-ExtUtils-MakeMaker perl
# kill script now and install as above, if needed.

# otherwise, take a break! get some rest!
# It will take about 1.5hrs (~3-4hrs Ubuntu VM), for this step to complete. 

#
# configuration written to ~/el/buildroot/.config
#

sleep 12
EOF

sleep 12
# ubuntu idiosyncracy.
# { egrep -i -q ubuntu /proc/version; } && \
# 	{ filewatchCP $HOME/el/buildroot/ltmain.sh ${HOME}/el/buildroot/output/build/host-fakeroot-1.25.3/ltmain.sh 0.5; }
sleep .5

time make
  
echo see "buildroot_instructions.txt" for next steps.

cat >${CWD}/buildroot_instructions.txt<<EOF
Now that buildroot step is successfully complete in `pwd`

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
EOF
