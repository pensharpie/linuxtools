#!/bin/bash -a

cat <<-EOF
	use appropriate defconfig
##
## --
##
	rpi_0_w_defconfig
	rpi_2_defconfig
	rpi_3_32b_defconfig
	rpi_3_b_plus_defconfig
	rpi_3_defconfig
	rpi_4_32b_defconfig
	rpi_4_defconfig
	rpi_arm64_defconfig
	rpi_defconfig
##
## --
##
using rpi_4_defconfig
- if you are using RPi 3 or 3B
- press ^C and exit from this script,
- and, make 2 changes (lines 26,27 below)
  a) change arch64-rpi4 on line 26 to that as in the crosstool-ng assignment
  b) change defconfig on line 27
EOF
## --
echo "sleep 12"
sleep 12

M_ARCH="aarch64-rpi4"
M_CONFIG="rpi_4_defconfig"
export PATH=${HOME}/x-tools/${M_ARCH}-linux-gnu/bin/:$PATH
export CROSS_COMPILE=${M_ARCH}-linux-gnu-

cd ~/el/u-boot
make ${M_CONFIG}
time make
