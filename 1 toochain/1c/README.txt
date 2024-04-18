Use this link
https://gist.github.com/rnagarajanmca/c8d1a086d3b0546575be0811b9a863c3

https://www.instructables.com/Raspberry-Pi-Emulator-for-Windows-10/

Download
1. https://downloads.raspberrypi.org/raspios_full_armhf/images/raspios_full_armhf-2022-01-28/2022-01-28-raspios-bullseye-armhf-full.zip
or
2. https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2022-01-28/2022-01-28-raspios-bullseye-armhf-lite.zip
and then, from https://github.com/dhruvvyas90/qemu-rpi-kernel
3. https://github.com/dhruvvyas90/qemu-rpi-kernel/blob/master/kernel-qemu-5.10.63-bullseye
4. https://github.com/dhruvvyas90/qemu-rpi-kernel/blob/master/versatile-pb-bullseye-5.10.63.dtb

RPI2
https://raspberrypi.stackexchange.com/questions/117234/how-to-emulate-raspberry-pi-in-qemu
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
