Creating a Cross-Platform Toolchain for Raspberry Pi 4
see https://ilyas-hamadouche.medium.com/creating-a-cross-platform-toolchain-for-raspberry-pi-4-5c626d908b9d

https://raspberrypi.stackexchange.com/questions/91475/crosscompiling-exact-archictecture-for-all-models
What is the exact architecture parameter for each Raspberry Pi model?
Acronyms, from RPi's website:

Based on Broadcom SoC's.
Raspberry Pi 1, Model A, B, B+, the Compute Module, and the Raspberry Pi Zero: 
  ARM11 76JZF-S .. is part of ARM11 family meaning armv6 - in a BCM2835 SoC.
Raspberry Pi 2 Model B, rev 1.1: 
  ARM Cortex-A7 is part of Cortex-A family meaning armv7a - in a BCM2836 SoC.
Raspberry Pi 2, rev 1.2, and 
Raspberry Pi 3: 
  ARM Cortex-A53 is part of Cortex-A family meaning armv8a - in a BCM2837 SoC.
Raspberry Pi 3 A+ and B+: 
  as above, ARM Cortex-A53 has armv8a but - in a BCM2837B0 SoC.
Raspberry Pi 4 B: 
Raspberry Pi 400: 
  ARM Cortex-A72 has armv8a - in a BCM2711C0 SoC (since November 2021).

see https://en.wikipedia.org/wiki/Raspberry_Pi#Model_comparison

Raspberry Pi 3 and 4 have 64-bit CPUs. 
However, Raspbian is a 32-bit operating system, so that SD card images work on all Pi models.

https://azeria-labs.com/arm-on-x86-qemu-user/

Raspberry Pi 4
The Raspberry Pi 4 is a huge step forward in performance. It’s a much faster computer. 
However, it’s not a new architecture. 
Like the Pi3/3+ it contains an Armv8 CPU which can run a 32-bit (Armv7) operating system in Pi-1 compatible userland (Armv6). 
This means Armv7-optimised (NEON) code will work on it, but so will Armv6 code, just like the Pi 2 and 3.

Raspberry Pi 4 Model B was released in June 2019 with a 1.5 GHz 64-bit quad core ARM Cortex-A72 processor
