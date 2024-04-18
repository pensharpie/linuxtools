#!/bin/bash -a

## see https://gist.github.com/rnagarajanmca/c8d1a086d3b0546575be0811b9a863c3

PIosl="2022-01-28-raspios-bullseye-armhf-lite.img"
PIosf="2022-01-28-raspios-bullseye-armhf-full.img"
PIknl="kernel-qemu-5.10.63-bullseye"
PIdtb="versatile-pb-bullseye-5.10.63.dtb"
#
# sudo qemu-img resize ${PIosl} +4G
Step1() 
{
OS=${1:-"lite"}
[ "${OS}" = "lite" ] && { PIos=$PIosl; } || { PIos=$PIosf; }

sudo qemu-system-arm \
	-M versatilepb -cpu arm1176 -m 256 \
	-drive "file=${PIos},index=0,media=disk,format=raw" \
	-append "root=/dev/sda2 panic=1 rootfstype=ext4 rw init=/bin/bash" \
	-net nic -net user,hostfwd=tcp:127.0.0.1:2222-:22 \
	-kernel ${PIknl} \
	-dtb ${PIdtb} \
	-no-reboot -serial stdio 
}

Step2() 
{
OS=${1:-"lite"}
[ "${OS}" = "lite" ] && { PIos=$PIosl; } || { PIos=$PIosf; }
sudo qemu-system-arm \
-M versatilepb -cpu arm1176 -m 256 \
-drive "file=${PIos},index=0,media=disk,format=raw" \
-append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" \
-net nic -net user,hostfwd=tcp:127.0.0.1:2222-:22 \
-kernel ${PIknl} \
-dtb ${PIdtb} \
-no-reboot -serial stdio
}

Unused()
{
qemu-system-arm \
  -M versatilepb \
  -cpu arm1176 \
  -m 256 \
  -drive "file=raspbian_backup-2.img,if=none,index=0,media=disk,format=raw,id=disk0" \
  -device "virtio-blk-pci,drive=disk0,disable-modern=on,disable-legacy=off" \
  -net "user,hostfwd=tcp::5022-:22" \
  -dtb versatile-pb-buster-5.4.51.dtb \
  -kernel kernel-qemu-5.4.51-buster \
  -append 'root=/dev/vda2 panic=1' \
  -no-reboot

qemu-system-arm -kernel kernel-qemu-4.4.34-jessie 
  -M versatilepb -cpu arm1176 -m 256 
  -drive "file=2017-07-05-raspbian-jessie.img,index=0,media=disk,format=raw" 
  -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw init=/bin/bash" 
  -net nic -net user,hostfwd=tcp::2222-:22
  -no-reboot -serial stdio 
}

# sudo apt-get update && sudo apt-get upgrade
# sudo systemctl enable ssh
# sudo systemctl start ssh

# Step1 lite
# Step1 full

# Step2 lite
Step2 full
