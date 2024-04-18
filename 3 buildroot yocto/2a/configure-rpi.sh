#!/bin/bash -a

rpi=${1:-"raspberrypi4-64"}

##
## Raspberry Pi options supported:
##
## raspberrypi0-2w-64
## raspberrypi0-2w
## raspberrypi0
## raspberrypi0-wifi
## raspberrypi2
## raspberrypi3-64
## raspberrypi3
## raspberrypi4-64
## raspberrypi4
## raspberrypi-armv7
## raspberrypi-armv8
## raspberrypi-cm3
## raspberrypi-cm
## raspberrypi
##

set -e
D="`pwd`"
mkdir -p log ~/el/poky
rm -f log/download.html* log/index.html* log/Releases

echo "See \"https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html\" for more reading & details."

## needed for linux-firmware-rpidistro-bcm43455
export LICENSE_FLAGS_ACCEPTED="synaptics-killswitch"

# 0a. figure out which version is latest stable release.
cd log
wget -q https://wiki.yoctoproject.org/wiki/Releases
LatestCodeName="`sed -e 's/<td>//g' -e 's/<br .>//' -e 's/ *<.*> *//g' Releases | egrep -v \"^$\" | egrep -B 4 \"^Support for [0-9]* months \\\(until\" | head -1 | awk '{printf(\"%s\",$1);}' | tr [A-Z] [a-z]`"
LatestRelease="`sed 's/ *<.*> *//g' Releases | egrep -v \"^$\" | egrep -B 3 \"^Support for [0-9]* months \\\(until\" | head -1 | awk '{printf(\"%s\",$1);}'`"
cat <<EOF
using Yocto Project version: $LatestRelease as latest stable release.
- with CodeName: "$LatestCodeName"
EOF

# 0b: Install YoctoProject by cloning the repository.
#
# --
## set in build/local.conf 
## --  share-state-cache and reuse it for further build.
## --  share-state-cache mechanism to determine which recipes need to rebuild
## SSTATE_DIR="${HOME}/el/poky/sstate-cache-dir"
## --  Save the downloads directory
## DL_DIR="${HOME}/el/poky/download-dir/"
# mkdir -p $SSTATE_DIR $DL_DIR
# --

# 0b. installs .. as needed.
cd ~/el
[ -d poky ] && \
  { echo "theYoctoProject $(grep DISTRO_CODENAME ~/el/poky/meta-poky/conf/distro/poky.conf | sed -e 's/.* "//' -e 's/"$//') already installed."; }  || \
  { git clone -b $LatestCodeName git://git.yoctoproject.org/poky.git; }

cd ~/el/poky
[ -d meta-openembedded ] || \
	{ git clone -b $LatestCodeName git://git.openembedded.org/meta-openembedded; }
[ -d meta-raspberrypi ] || \
	{ git clone -b $LatestCodeName git://git.yoctoproject.org/meta-raspberrypi; }

# 1. Navigate to poky directory
cd ~/el/poky

# 2. chdir to directory inside raspberrypi BSP layer
#    and, list the Raspberry Pi images
cd meta-raspberrypi/recipes-core/images
ls -l

# 3. setup BitBake work environmnet
cd ~/el/poky
source oe-init-build-env build-rpi

# 4. add BitBake layers to the image.
cd ~/el/poky/build-rpi
bitbake-layers add-layer ../meta-openembedded/meta-oe
bitbake-layers add-layer ../meta-openembedded/meta-python
bitbake-layers add-layer ../meta-openembedded/meta-networking
bitbake-layers add-layer ../meta-openembedded/meta-multimedia
bitbake-layers add-layer ../meta-raspberrypi

# 5. show BitBake layers
bitbake-layers show-layers

# 6. verify assignment of BBLAYERS variable
cd ~/el/poky/build-rpi
egrep "BBLAYERS" conf/bblayers.conf

# 7. List the machines supported by the meta-raspberrypi BSP layer
cd ~/el/poky
ls meta-raspberrypi/conf/machine

# 8. add rpi and ssh to local.conf
{ egrep -q "$rpi" ~/el/poky/build-rpi/conf/local.conf; } || \
	{ cp ~/el/poky/build-rpi/conf/local.conf ~/el/poky/build-rpi/conf/local.conf.old; \
		sed -i "s/#MACHINE ?= \"qemuarm\"/MACHINE = \"$rpi\"/" ~/el/poky/build-rpi/conf/local.conf; }
{ egrep -q "ssh-server-openssh" ~/el/poky/build-rpi/conf/local.conf; } || \
	{ sed -i 's/debug-tweaks/& ssh-server-openssh/' ~/el/poky/build-rpi/conf/local.conf; }


## new for mickledore 
{ egrep -i -q "synaptics-killswitch" ~/el/poky/build-rpi/conf/local.conf; } || \
  { echo "LICENSE_FLAGS_ACCEPTED = \"synaptics-killswitch\"" >> ~/el/poky/build-rpi/conf/local.conf; }

# 9. build & bitbake
echo "this part takes ~6hours."
time -p bitbake rpi-test-image 2>&1 

#10. image file location
cd ~/el/poky/build-rpi/
ls -l tmp/deploy/images/${rpi}/rpi-test*wic.bz2
