2/20/2024 toolchain steps for a RPI-4
unzip Chapter_02.zip
cd 1
sudo apt -y update
sudo apt -y install automake bison chrpath flex gcc make perl g++ git gperf gawk help2man libexpat1-dev libncurses5-dev libsdl1.2-dev libtool libtool-bin libtool-doc python2.7-dev texinfo libglib2.0-dev python3-dev libglib2.0-dev texinfo help2man qemu-system-arm qemu-efi
make
cd 1a
update Makefile for the target platform, rpi4 in my case.  See next line for update.
./configure-Crosstoll-ng_rpi.sh rpi4 | tee crosstoll.out
make

###

2/20/2024 manual steps to a kernel and rootfs
unzip Chapter_03.zip
cd 1
execute Steps.sh

###
