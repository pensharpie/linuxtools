#!/bin/bash -a

# Step#1. Get latest version U-Boot.
mkdir -p ~/el/log
cd ~/el/log
wget -q https://u-boot.readthedocs.io/en/latest/develop/release_cycle.html 
Latest=$(egrep " was released on " release_cycle.html | head -1 | sed 's~</*[lp]i*>~~g')
LatestRelease="`echo $Latest | awk '{print $2}'`"
LatestRelDT="`echo $Latest | awk '{print $(NF-3), $(NF-2), $(NF-1),$NF}'`"
echo "using ${bold}U-Boot${normal} $LatestRelease released $LatestRelDT"
cd ~/el
git clone git://git.denx.de/u-boot.git
cd u-boot
git checkout $LatestRelease 2>&1 | tee  ../log/git_checkout_U-Boot-${LatestRelease}.log >/dev/null
cd ../
cat <<EOF
 look for default configs in ~/el/u-boot/configs

 e.g.
 RPi
 - rpi_0_w_defconfig
 - rpi_2_defconfig
 - rpi_3_32b_defconfig
 - rpi_3_b_plus_defconfig
 - rpi_3_defconfig
 - rpi_4_32b_defconfig
 - rpi_4_defconfig
 - rpi_arm64_defconfig
 - rpi_defconfig
 BB
 - am335x_evm_defconfig  (pg 65) 
EOF

