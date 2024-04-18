#!/bin/bash -a

TGT=${1:-"rpi4"}
## C & C++ compile locally
gcc -o helloc hello.c
g++ -o hellocpp hello.cpp
file helloc hellocpp
./helloc
./hellocpp

## cross-compile for ${TGT} in C, C++
export PATH=$PATH:~/x-tools/aarch64-${TGT}-linux-gnu/bin
aarch64-${TGT}-linux-gnu-gcc hello.c -o ${TGT}-helloc
aarch64-${TGT}-linux-gnu-g++ hello.cpp -o ${TGT}-hellocpp
file ${TGT}-helloc ${TGT}-hellocpp
echo "Success!"
