#!/bin/bash -a

set -e
D="`pwd`"
mkdir -p log

rm -f log/download.html*

useTAR()
{
	rm -f ${D}/buildroot-${LatestRelease}.tar.gz
	wget -q https://buildroot.org/downloads/buildroot-${LatestRelease}.tar.gz
	cd ~/el
	rm -fr buildroot*
	tar xzf ${D}/buildroot-${LatestRelease}.tar.gz
	ln -s buildroot-${LatestRelease} buildroot
}

## Step 1: figure out which version is latest stable release.
cd log
wget -q https://buildroot.org/download.html
LatestRelease="`egrep -i \"Latest stable release\" download.html | grep -v rc | head -1 | sed -e 's/\/a//g' -e 's/[<>]/ /g' -e 's/ed/e/g' | sed 's/\/..//g' | awk '{print $NF}'`"
echo "using buildroot : $LatestRelease as latest stable release"
cd ..

## Step 2: Install Buildroot by cloning the repository.
# git clone command did not work, so downloaded the tarball
cd ~/el
rm -fr buildroot*
git clone git://git.buildroot.org/buildroot -b "$LatestRelease"
cd buildroot

## Step 3:
if egrep -i -q "ubuntu|debian" /proc/version
then
cat <<EOF
For Ubuntu
background to the ltmain.sh issue: 
  https://www.gnu.org/software/automake/manual/1.9/html_node/Libtool-Issues.html
  https://stackoverflow.com/questions/8142685/buildroot-applying-a-patch-failed
  libtoolize --automake --copy --debug --force
install packages as below.
  sudo apt -y install gawk wget git-core diffstat unzip \
        texinfo gcc-multilib build-essential chrpath \
        at cpio python python3 python3-pip python3-pexpect \
        xz-utils debianutils iputils-ping libsdl1.2-dev xterm \
        chrpath diffstat perl python3-passlib libsqlite3-dev \
        sqlite3 zstd liblz4-tool autoconf libtool
  sudo pip install wheel pysqlite3
  cd $HOME/el/buildroot
  # use bash shell for below
  bash libtoolize --automake --copy --debug --force
EOF
  set -x
  cd $HOME/el/buildroot
  # use bash shell for below
  bash libtoolize --automake --copy --debug --force > $D/log/libtoolize.out 2>&1
else
cat <<EOF
For RHEL/Centos/Fedora
install packages as below.
  sudo dnf -y install gawk wget git-core diffstat \
        unzip texinfo glibc-devel libstdc++-devel make \
        automake gcc gcc-c++ kernel-devel chrpath at \
        cpio python python3 python3-pip python3-pexpect \
        xterm chrpath diffstat rpcgen perl-open \
        python3-passlib python3-devel sqlite-devel \
        libsqlite3x libsqlite3x-devel
  sudo pip install wheel pysqlite3
EOF
fi

