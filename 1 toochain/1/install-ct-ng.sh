## Need packages:
## - Ubuntu/Raspbian/Debian etc:"libglib2.0-dev texinfo help2man"
## - Fedora/RedHat*/CentOS  etc:"glib2-devel texinfo help2man"
##
##
##  Step #0. create a log dir locally and keep things there.
##           typically fastidous approaches will necessitate usage of TMPDIR 
##           - but not investing n that for now/here.
D="`pwd`"
mkdir -p ~/el ~/src
cd ~/el
mkdir -p log
rm -f log/*.log log/*html*

echo "run make in $D to install from there" > log/README.txt

DIST="`cat /proc/version | sed -e 's/.*Ubuntu.*/Ubuntu/g' -e 's/.*Red *Hat.*/RedHat/g'`"
echo $DIST

if echo $DIST | grep -i ubuntu
then
	PKGLIST="libglib2.0-dev texinfo help2man"
	cat <<EOF
  echo "need to add the following packages ${PKGLIST}"
  commands to run:
	sudo apt -y update
  sudo apt -y install automake bison chrpath flex gcc make perl g++ git gperf gawk help2man libexpat1-dev libncurses5-dev libsdl1.2-dev libtool libtool-bin libtool-doc python2.7-dev texinfo libglib2.0-dev python3-dev libglib2.0-dev texinfo help2man qemu-system-arm qemu-efi
  # sudo apt-get -y install libglib2.0-dev texinfo help2man python3-devel
EOF
else
  # for the following packages: AlmaLinux, ALT Linux, CentOS, Fedora, Mageia, OpenMandriva, openSUSE, PCLinuxOS, Rocky Linux, Solus
	PKGLIST="glib2-devel texinfo help2man"
	cat <<EOF
  echo "need to add the following packages ${PKGLIST}"
  commands to run:
  sudo dnf -y install glib2-devel texinfo help2man python3-devel
EOF
fi


##
##  Step #1. figure out LatestRelease & LatestRelDT
##  
cd log
wget -q https://crosstool-ng.github.io/
LatestRelease="`grep -i released index.html | grep -v rc | head -1 | sed -e 's/\/a//g' -e 's/[<>]/ /g' -e 's/ed/e/g' | awk '{print $NF}'`"
LatestRelDT="`grep -i released index.html | head -1 | sed -e 's/.*href=\"\///g' -e 's/\/release.*//g' -e 's/\//-/g'`"
echo "using ${bold}crosstool-ng${normal} $LatestRelease released $LatestRelDT"
cd ..


##
##  Step #2. git - clone and checkout
##  
[ \( -d crosstool-ng \) -a \( -d crosstool-ng/.git \) ] && \
	{ echo "removing existing crosstool-ng and reinstalling"; rm -rf crosstool-ng; }
echo "git clone https://github.com/crosstool-ng/crosstool-ng.git"
git clone https://github.com/crosstool-ng/crosstool-ng.git 2>&1 | tee log/git_clone.log >/dev/null
cd crosstool-ng
echo "git checkout crosstool-ng-${LatestRelease}"
git checkout crosstool-ng-${LatestRelease} 2>&1 | tee  ../log/git_checkout_crosstool-ng-${LatestRelease}.log >/dev/null

##
##  Step #3. configure & install
##  
echo "./bootstrap"
./bootstrap 2>&1 | tee ../log/bootstrap.log >/dev/null
echo "see \"https://kimmo.suominen.com/blog/2019/12/fix-broken-autoconf-files/\" for background on \"gl_HOST_CPU_C_ABI_32BIT: not found\" message seen"
sleep 5
echo "./configure --prefix=${PWD}"
./configure --prefix=${PWD} | tee ../log/configure--prefix.log >/dev/null
echo "make"
make 2>&1 | tee ../log/make.log >/dev/null
echo "make install"
make install 2>&1 | tee ../log/make-install.log >/dev/null

##
##  Step #4. End.
##  
echo ""
echo ""
echo ""
cat <<EOF
## --
  Success!
  All logs are in `pwd`/log
  the program is installed to the `pwd` directory, 
  - which avoids the need for root permissions 
  - that would be needed for install to the default location /usr/local/share.
 	this is a working install of crosstool-NG that will be used for building cross toolchains.
  type 
    cd `pwd`
    bin/ct-ng 
  to launch crosstool menu.

  also export MANPATH="\$MANPATH:`pwd`/share/man" to your bashrc
## --
EOF
