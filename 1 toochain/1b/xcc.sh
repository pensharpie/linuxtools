#!/bin/bash -ax
## cross-compile for rpi4 in C, C++
export PATH=$PATH:~/x-tools/arm-cortex_a8-linux-gnueabihf/bin
arm-cortex_a8-linux-gnueabihf-gcc hello.c -o bbb-helloc
arm-cortex_a8-linux-gnueabihf-g++ hello.cpp -o bbb-hellocpp
file bbb-helloc bbb-hellocpp
echo "Success!"
