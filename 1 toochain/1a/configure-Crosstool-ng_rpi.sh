#!/bin/bash -a
#################################################

## valid values are rpi3 or rpi4
CTTGT=${1:-"rpi4"}  ## if not provided on command line assume rpi4
CTTGT=${1:-"rpi3"}  ## if not provided on command line assume rpi4
#
## Use for 
## rpi4, or 
## rpi3 for - rpi3B+, rpi3B

## use the following command
## cd ~/el/crosstool-ng/
## ./bin/ct-ng list-samples | grep -i rpi
#
#################################################
## https://ilyas-hamadouche.medium.com/creating-a-cross-platform-toolchain-for-raspberry-pi-4-5c626d908b9d
## https://www.raspberrypi.org/products/raspberry-pi-4-model-b/specifications/
## Broadcom BCM2711, Quad core Cortex-A72 (ARM v8) 64-bit SoC @ 1.5GHz

##
## Next line is to exit on error.
##
set -e	   

##
## save backups
##

## if config file exists and no backup
## then create backup
[ \( -f $HOME/el/crosstool-ng/.config \) -a  ! \( -f $HOME/el/crosstool-ng/.config.orig \) ] && \
	{ mv $HOME/el/crosstool-ng/.config $HOME/el/crosstool-ng/.config.orig 2>/dev/null; }
##
## initial steps
##
cat <<EOF
 not doing menuconfig
EOF
## ./bin/ct-ng menuconfig
## sleep 12
## read x


## ------- ##
CWD="`pwd`"
TCFG=$(echo ${CTTGT} | cut -c 1-4)

cd ~/el/crosstool-ng/
rm -f $HOME/el/crosstool-ng/.config 
## ------- ##

./bin/ct-ng list-samples | grep -i rpi
./bin/ct-ng show-aarch64-${TCFG}-linux-gnu 

ZLIB=$(~/el/crosstool-ng/bin/ct-ng show-aarch64-${TCFG}-linux-gnu | grep -i -E "Companion libs" | sed 's/.*zlib/zlib/' | awk '{print $1}')

[ -f ~/src/${ZLIB}.tar.gz ] || { mkdir -p ~/src; cp ${CWD}/${ZLIB}.tar.gz ~/src; }
./bin/ct-ng clean
./bin/ct-ng distclean

## Select a base-line configuration ..  aarch64-rpi3-linux-gnu 
./bin/ct-ng aarch64-${TCFG}-linux-gnu

## reset config file
# cp ${CWD}/config-${CTTGT}.expat-issue.txt $HOME/el/crosstool-ng/.config


## echo "Checking min Kernel version"
echo -n "Getting Kernel Version from \"uname -r\" .. "
read -r XKV YKV ZKV <<< $(uname -r | sed -e 's/\./ /g' -e 's/-.*//' | awk '{print $1, $2, $3}')
echo "${XKV}.${YKV}.${ZKV} .. done." 

echo -n "Getting Kernel Version from .config .. "
read -r XCT YCT ZCT <<< $(grep CT_LINUX_VERSION $HOME/el/crosstool-ng/.config | head -1 | \
	sed -e 's/.*="//' -e 's/"//g' -e 's/\./ /g' -e 's/-.*//' | awk '{print $(NF-2), $(NF-1), $NF}')
echo "${XCT}.${YCT}.${ZCT} .. done."

# Build Strings
CTS="${XCT}_${YCT}"
KVS="${XKV}_${YKV}"
[ "${ZKV}" -eq "0" ] && { KVF="${XKV}.${YKV}"; } || { KVF="${XKV}.${YKV}.${ZKV}"; }

Ubuntu2204IssueFix()
{
## make fixes to $HOME/el/crosstool-ng/.config
## with original saved to ${CWD}/original-config-$CTTGT.txt
# [ \( "$XCT" -le "$XKV" \) -a \( "$YCT" -le "$YKV" \) -a \( "$ZCT" -le "$ZKV" \) ] || \
## Ubuntu 22.04 Issue
[ \( "$XKV" -ge "$XCT" \) -a \( "$YKV" -ge "$YCT" \) -a \( "$ZKV" -ge "$ZCT" \) ] && \
  { echo "OK. Kernel Version $XKV.$YKV.$ZKV is HIGHER than CT-NG required ver $XCT.$YCT.$ZCT"; } || \
  { echo "Kernel Version $XKV.$YKV.$ZKV is LOWER than CT-NG required ver $XCT.$YCT.$ZCT"; \
    echo "Resetting .config in ~/el/crosstool-ng to match current kernel"; \
    cp $HOME/el/crosstool-ng/.config ${CWD}/original-config-${CTTGT}.txt; \
    sed -e "s/CT_LINUX_VERSION=.*/# &/" \
        -e "s/CT_GLIBC_MIN_KERNEL=.*/# &/" \
        -e "s/CT_LINUX_V_${CTS}=.*/# &/" \
        -e "s/CT_TARGET_VENDOR=.*/# &/" \
	$HOME/el/crosstool-ng/.config > ${CWD}/config-$CTTGT.txt.tmp2; \
    sed -e "/CT_LINUX_VERSION=.*/a CT_LINUX_VERSION=\"${KVF}\"" \
        -e "/CT_GLIBC_MIN_KERNEL=.*/a CT_GLIBC_MIN_KERNEL=\"${KVF}\"" \
        -e "/CT_LINUX_V_${KVS}.*/a CT_LINUX_V_${KVS}=y" \
        -e "/CT_TARGET_VENDOR=.*/a CT_TARGET_VENDOR=${CTTGT}" \
	${CWD}/config-$CTTGT.txt.tmp2 > ${CWD}/config-$CTTGT.txt.tmp; \
    cp ${CWD}/config-$CTTGT.txt.tmp $HOME/el/crosstool-ng/.config;
    rm -f ${CWD}/config-$CTTGT.txt.tmp ${CWD}/config-$CTTGT.txt.tmp2;
  }
}

## build here .. takes about 1hr.
echo ".. this next 2 step takes 60+ minutes."
./bin/ct-ng source
./bin/ct-ng build

##
## -- test compiles
##

echo ""
echo ""
echo ""
echo "Success!"
echo "Now Testing compiles"
cd $CWD
## C & C++ compile locally
gcc -o helloc hello.c
g++ -o hellocpp hello.cpp
file helloc hellocpp
./helloc
./hellocpp

## cross-compile for $CTTGT in C, C++
export PATH=$PATH:~/x-tools/aarch64-${CTTGT}-linux-gnu/bin
aarch64-${CTTGT}-linux-gnu-gcc hello.c -o ${CTTGT}-helloc
aarch64-${CTTGT}-linux-gnu-g++ hello.cpp -o ${CTTGT}-hellocpp
file ${CTTGT}-helloc ${CTTGT}-hellocpp
echo "Success!"
