sudo mount /dev/sdb1 /mnt/boot
sudo mount /dev/sdb2 /mnt/root
exit

#####################################################################
## ------------------------------------------------------------------
## four components of embedded Linux – 
## - toolchain, 
## - bootloader, 
## - kernel and 
## - root filesystem – 
## ------------------------------------------------------------------
#####################################################################

## Build an SD card for Raspberry Pi 3 or 4 from scratch.

##
## ------------------------------------------------------------------
##

## Step 1.  Requirements.
## a. HOST   - Linux machine. (atleast a vm). Use Ubuntu, if possible.
## b. TARGET - RPi 3 or 4. 
##             steps are for RPi 4, as default 
##             - however, for RPi 3 - please modify per instructions.
## c. SD card - either 2G,4G,8G,16G or 32G.
## d. SD card reader. 

##
## ------------------------------------------------------------------
##

## Step 2.  Prepare SD card.

## a. find SD card name
##      i) insert SD Card into SD Card Reader on Ubuntu Linux Host.
##     ii) Run this command
           dmesg | tail | egrep "sd.:" | sort -u | sed 's/\[.*.*\] *//'
##         It will show something on the lines of
##         sdb: sdb1
##         or 
##         sdb: sdb1 sdb2
##         
##         If you see sdc or sdd, then there some other storage.
##         Please be mindful - only to use the above, and not anything else .. 

## b. getting existing partitions
##    -- - Run this command
           sudo fdisk -lu /dev/sdb 
##         the last couple of lines will show something similar to
##         Device     Boot Start      End  Sectors  Size Id Type
##         /dev/sdb1        2048 62332927 62330880 29.7G  c W95 FAT32 (LBA) 
##         then, proceed to #2c
##
##         If instead, you see something similar to 
##         Device     Boot  Start     End Sectors  Size Id Type
##         /dev/sdb1         8192  532479  524288  256M  c W95 FAT32 (LBA)
##         /dev/sdb2       532480 8577023 8044544  3.8G 83 Linux
##         then, skip #2c
##               as you already have the 2nd partition
##               goto #2d

## c. delete existing partitions (only if /dev/sdb2 does not exist).  
           sudo umount /dev/sdb1
##         There should be no errors for above.
##         WARNING: Be very careful to run the next step. 
##                  It will clobber everything on /dev/sdb.
           sudo sfdisk --force /dev/sdb < ./sdb.sfdisk.txt
##                  as above, it will create 2 partitions
##                  - one with 256M, and the 
##                  - other with ~4G

## d. make sure there are 2 partitions.
##         To check, run
           sudo fdisk -lu /dev/sdb
##         you should see something similar to 
##         Device     Boot  Start     End Sectors  Size Id Type
##         /dev/sdb1         8192  532479  524288  256M  c W95 FAT32 (LBA)
##         /dev/sdb2       532480 8577023 8044544  3.8G 83 Linux

## e. format partitions.
##         # boot partition - FAT32
           sudo mkfs.vfat -F 32 -n BOOT /dev/sdb1
##         # root partition - ext4
           sudo mkfs.ext4 -L ROOT /dev/sdb2

## f. mount partitions.
##         # create the paths
           sudo mkdir -p /mnt/boot /mnt/root
##         # boot partition - FAT32 on /mnt/boot
           sudo mount /dev/sdb1 /mnt/boot
##         # root partition - ext4
           sudo mount /dev/sdb2 /mnt/root

##
## ------------------------------------------------------------------
##

## Step 3. Toolchain.
##         As in Chapter 2 ex #1, 1a,1b, or 1c

## a. Download crosstool-ng source & switch to latest release
           cd ~/el/log
           wget -q https://crosstool-ng.github.io/
           LatestRelease="`grep -i released index.html | grep -v rc | head -1 | sed -e 's/\/a//g' -e 's/[<>]/ /g' -e 's/ed/e/g' | awk '{print $NF}'`"
           LatestRelDT="`grep -i released index.html | head -1 | sed -e 's/.*href=\"\///g' -e 's/\/release.*//g' -e 's/\//-/g'`"
           echo "using ${bold}crosstool-ng${normal} $LatestRelease released $LatestRelDT"
           cd ~/el
           git clone https://github.com/crosstool-ng/crosstool-ng
           cd crosstool-ng/
           git checkout crosstool-ng-${LatestRelease} 

## b. Build and Install crosstool-ng
           ./bootstrap
           ./configure --prefix=${PWD}
           make
           make install
           export PATH="${PWD}/bin:${PATH}" 

## c. Configure & Build crosstool-NG .. using defconfig provided for rpi4
           ./ct-ng show-aarch64-rpi4-linux-gnu
           ./ct-ng aarch64-rpi4-linux-gnu
           ./ct-ng build

##
## ------------------------------------------------------------------
##

## Step 4. U-Boot bootloader
##         As in Chapter 2 ex #2, 2a

## a. Download latest u-boot
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
           git checkout ${LatestRelease}

## b. Configure & Build u-boot .. using defconfig provided for rpi4
           export PATH=${HOME}/x-tools/aarch64-rpi4-linux-gnu/bin/:$PATH
           export CROSS_COMPILE=aarch64-rpi4-linux-gnu-
           make rpi_4_defconfig  
           make

## c.  Install U-Boot
           sudo cp u-boot.bin /mnt/boot 
##         NOTE: 
##           i) RPi has its own proprietary bootloader. 
##          ii) It is loaded by ROM code and then loads the kernel. 
##         iii) However, since we are using the open source u-boot -
##              we need to 
##              - configure the Raspberry Pi boot loader to load u-boot.
##              - and, then have u-boot to load the kernel.
           cat <<EOF
	make sure that an SD card with 2 empty partitions is in the Linux HOST
	- if ok, press Enter
	- if not, press ^C and follow instructions in Prepare-SD-Card.txt
EOF
read x

						mkdir -p ~/el/firmware
						cd ~/el/firmware

##          ## step #c1: copy u-boot.bin to /boot
            sudo cp ~/el/u-boot/u-boot.bin /mnt/boot 

##          ## step #c2: download latest RPi /boot directory
            svn checkout https://github.com/raspberrypi/firmware/trunk/boot
            sudo cp boot/bootcode.bin /mnt/boot/
            sudo cp boot/start4.elf /mnt/boot/

##          ## step #c3: create config.txt to notify RPi bootloader to load U-Boot.
cat <<-EOF > config.txt
  enable_uart=1
  arm_64bit=1
  kernel=u-boot.bin
EOF
            sudo cp config.txt /mnt/boot/

##
## ------------------------------------------------------------------
##

## Step 5. Kernel
##         using RPi’s fork instead of original Linux kernel.
##         Note: Host kernel version must be higher than kernel version configured in toolchain .config  

## ---
## a. Using RPi fork.
##    Note - watch for "Fatal: kernel too old." error - during boot.
##      i. Download latest kernel source for Raspberry Pi - using Raspberry Pi's fork.
					 cd ~/el/log
					 wget -q https://github.com/raspberrypi/linux
           OSVer=$(grep zip linux|grep href| sed -e 's~.*rpi-~rpi-~' -e 's/[">][">]*//' -e 's/\.zip//g') 
           mkdir -p ~/el/rpi-kernel
           cd ~/el/rpi-kernel
           git clone --depth=1 -b ${OSVer} https://github.com/raspberrypi/linux.git
           cd linux 

##     ii. Configure & Build kernel .. using defconfig provided for rpi4 (total takes about 1hr)
           cd ~/el/rpi-kernel/linux
					 export PATH=$PATH:~/x-tools/aarch64-rpi4-linux-gnu/bin 
           time -p make ARCH=arm64 CROSS_COMPILE=aarch64-rpi4-linux-gnu- bcm2711_defconfig
           time -p make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-rpi4-linux-gnu-

##    iii. Copy Kernel Image and default dtb to /boot
           sudo cp arch/arm64/boot/Image /mnt/boot
           sudo cp arch/arm64/boot/dts/broadcom/bcm2711-rpi-4-b.dtb /mnt/boot/
## ---
## b. Using stock Linux Kernel
## ---
##      i. Download latest kernel source for Raspberry Pi - using Raspberry Pi's fork.
           mkdir -p ~/el/kernel.org
           cd ~/el/kernel.org
					 wget -q https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.19.tar.xz
           tar xf linux-5.19.tar.xz 
           cd linux-5.19 

##     ii. Configure & Build kernel .. using defconfig provided for rpi4 (total takes about 1hr)
           cd ~/el/kernel.org/linux-5.19 
					 export PATH=$PATH:~/x-tools/aarch64-rpi4-linux-gnu/bin 
           ## it gets defconfig from arch/$ARCH/configs/defconfig
           time -p make ARCH=arm64 CROSS_COMPILE=aarch64-rpi4-linux-gnu- defconfig
           ## or, alternatively
           cp bcm2711_defconfig.txt ~/el/kernel.org/linux-5.19/.config
           time -p make ARCH=arm64 CROSS_COMPILE=aarch64-rpi4-linux-gnu- oldconfig

##         now build the kernel
           time -p make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-rpi4-linux-gnu-

##    iii. Copy Kernel Image and default dtb to /boot
           sudo cp arch/arm64/boot/Image /mnt/boot
           sudo cp arch/arm64/boot/dts/broadcom/bcm2711-rpi-4-b.dtb /mnt/boot/
## ---
##
## ------------------------------------------------------------------
##

## Step 6. RootFS
##         using Raspberry Pi’s fork instead of original Linux kernel.
##         Note: Host kernel version must be higher than kernel version configured in toolchain .config  

## a. Create Directories 
           mkdir -p ~/el/rootfs
           cd ~/el/rootfs
           mkdir {bin,dev,etc,home,lib64,proc,sbin,sys,tmp,usr,var}
           mkdir usr/{bin,lib,sbin}
           mkdir var/log
           ln -s lib64 lib # Create softlink lib pointing to lib64
           tree -d  # to check & verify
           sudo chown -R root:root * # Change the owner of the directories to be root

## b. Build & Install Busybox
##      i) Download the source code
           cd ~/el/log
           sudo rm downloads
           sync; sync; sync;
           wget -q https://busybox.net/downloads
           LatestRel=$(grep bz2 downloads|egrep -v -e "\.\."|sed -e 's/.*busybox-/busybox-/g' -e 's/\.bz2.*/\.bz2/' | tail -1)
					 mkdir -p ~/el/busybox
           cd ~/el/busybox
           wget -q https://busybox.net/downloads/${LatestRel}
           tar xf ${LatestRel}
           BBDIR=$(echo ${LatestRel} | sed 's/\.tar\.bz2//')
           cd ${BBDIR}

##     ii) Configure & Build .. using defconfig
           export PATH=${HOME}/x-tools/aarch64-rpi4-linux-gnu/bin/:$PATH
           export CROSS_COMPILE=${HOME}/x-tools/aarch64-rpi4-linux-gnu/bin/aarch64-rpi4-linux-gnu-
           make CROSS_COMPILE="$CROSS_COMPILE" defconfig
           # Change install directory in .config
           BBHOMESTR="$HOME/el/rootfs"
           eval sed -i 's~^CONFIG_PREFIX=.*$~CONFIG_PREFIX="${BBHOMESTR}"~' .config
           make CROSS_COMPILE="$CROSS_COMPILE"

##    iii) Install .. everything will go into $BBHOMESTR
           sudo make CROSS_COMPILE="$CROSS_COMPILE" install
           sudo chmod 4755 $HOME/el/rootfs/bin/busybox

##     iv) Copy Libraries
           export SYSROOT=$(aarch64-rpi4-linux-gnu-gcc -print-sysroot)
           sudo cp -L ${SYSROOT}/lib64/{ld-linux-aarch64.so.1,libm.so.6,libresolv.so.2,libc.so.6} \
             ~/el/rootfs/lib64/

##      v) Create Device nodes needed by BusyBox
           cd ~/el/rootfs
           sudo mknod -m 666 dev/null c 1 3
           sudo mknod -m 600 dev/console c 5 1

##
## ------------------------------------------------------------------
##

## Step 7. Booting
##         using Raspberry Pi’s fork instead of original Linux kernel.

           sudo mount /dev/sdb1 /mnt/boot
           sudo mount /dev/sdb2 /mnt/root
           sudo df -Ph

## Use either
## a. Boot with InitRamFS
##      i) Build initramfs && Copy initramfs to boot partition
           cd ~/el/rootfs
           find . | cpio -H newc -ov --owner root:root -F ../initramfs.cpio
           cd ..
           gzip initramfs.cpio
           ~/el/u-boot/tools/mkimage -A arm64 -O linux -T ramdisk -d initramfs.cpio.gz uRamdisk
           sudo cp uRamdisk /mnt/boot/ 

##     ii) Configure U-Boot && Copy compiled boot script to boot partition
           cat <<-EOF > boot_cmd.txt
fatload mmc 0:1 \${kernel_addr_r} Image
fatload mmc 0:1 \${ramdisk_addr_r} uRamdisk
setenv bootargs "console=serial0,115200 console=tty1 rdinit=/bin/sh"
booti \${kernel_addr_r} \${ramdisk_addr_r} \${fdt_addr}
EOF
           ~/el/u-boot/tools/mkimage -A arm64 -O linux -T script -C none -d boot_cmd.txt boot.scr
           sudo cp boot.scr /mnt/boot/

##    iii) Finally Boot RPi 4.
         # unmount the partitions 
           tree /mnt/boot # should show 0 dirs and 7 files.
           sudo umount /dev/sdb1
           sudo umount /dev/sdb2
         # insert the SD card into RPi 4 
         # and, reboot.
     
## or, alternatively
## b. Boot with RootFS
##      i) Copy rootfs to root partition on the SD card 
           sudo umount /dev/sdb1
           sudo umount /dev/sdb2
           sudo fsck -y /dev/sdb1
           sudo fsck -y /dev/sdb2
           sudo mount /dev/sdb1 /mnt/boot  
           sudo mount /dev/sdb2 /mnt/root 
           sudo cp -r ~/el/rootfs/* /mnt/root/ 

##     ii) Configure U-Boot && Copy compiled boot script to boot partition
           cat << EOF > boot_cmd.txt
fatload mmc 0:1 \${kernel_addr_r} Image
setenv bootargs "console=serial0,115200 console=tty1 root=/dev/mmcblk0p2 rw rootwait init=/bin/sh"
booti \${kernel_addr_r} - \${fdt_addr}
EOF
           ~/el/u-boot/tools/mkimage -A arm64 -O linux -T script -C none -d boot_cmd.txt boot.scr
           sudo cp boot.scr /mnt/boot/

##    iii) Finally Boot RPi 4.
         # unmount the partitions 
           tree /mnt/boot # should show dirs and files.
           sudo umount /dev/sdb1
           sudo umount /dev/sdb2
         # insert the SD card into RPi 4 
         # and, reboot.
     
