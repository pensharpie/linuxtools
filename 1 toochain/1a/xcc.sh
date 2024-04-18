#!/bin/bash -a
##
TGT=${1:-"rpi4"}

checks()
{
	ARGS="$*"
	## -- strip symbols
	echo "## --"
	echo "## --"
	echo "# -- before strip"
	ls -l ${TGT}-helloc helloc
	strip helloc
	aarch64-${TGT}-linux-gnu-strip ${TGT}-helloc 
	echo "# -- after strip"
	ls -l ${TGT}-helloc helloc
	echo "## --"
	echo "## --"
	## --
	file ${TGT}-helloc ${TGT}-hellocpp
	## --
	# qemu-aarch64 -r 6.0 -L /usr/aarch64-linux-gnu ./${TGT}-helloc
	# qemu-aarch64 -r 6.0 -L /usr/aarch64-linux-gnu ./${TGT}-hellocpp
	# qemu-aarch64 ${ARGS} ./${TGT}-helloc
	# qemu-aarch64 ${ARGS} ./${TGT}-hellocpp
        ## --
        echo "sleep 10"; 
        sleep 10
}
##
uname -r
uname -a
##
gcc -o helloc hello.c
g++ -o hellocpp hello.cpp
## cross-compile for ${TGT} in C, C++
echo "export PATH=$PATH:~/x-tools/aarch64-${TGT}-linux-gnu/bin"
export PATH=$PATH:~/x-tools/aarch64-${TGT}-linux-gnu/bin

echo "gcc -dumpmachine => $(gcc -dumpmachine)"
echo "aarch64-${TGT}-linux-gnu-gcc -dumpmachine => $(aarch64-${TGT}-linux-gnu-gcc -dumpmachine)"

## --
## --
## compile -- dynamic 
aarch64-${TGT}-linux-gnu-gcc hello.c -o ${TGT}-helloc 
aarch64-${TGT}-linux-gnu-g++ hello.cpp -o ${TGT}-hellocpp 
checks "-L /usr/aarch64-linux-gnu"

## --
## compile with "-static" to avoid LDD spec.
aarch64-${TGT}-linux-gnu-gcc hello.c -o ${TGT}-helloc -static
aarch64-${TGT}-linux-gnu-g++ hello.cpp -o ${TGT}-hellocpp -static
#  --
checks  "-r 6.0"
## --

cat <<EOS
qemu-aarch64 -L /usr/aarch64-linux-gnu ./${TGT}-helloc
qemu-aarch64 -L /usr/aarch64-linux-gnu ./${TGT}-hellocpp
echo "Success!"
oo()
{
cat <<EOF
  sudo apt -y install qemu-user qemu-user-static gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu binutils-aarch64-linux-gnu-dbg build-essential
  sudo yum -y install qemu-user qemu-user-static gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu
  scp -P 2222 ${TGT}-helloc* pi@localhost:el/Chapter_02/Examples/1a
EOF
}
EOS
