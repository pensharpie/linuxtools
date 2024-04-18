#!/bin/bash -a

set -e
D="`pwd`"
mkdir -p log ~/el

rm -f log/download.html* log/index.html* log/Releases*

## Step 1: figure out which version is latest stable release.
cd log
wget -q https://wiki.yoctoproject.org/wiki/Releases
# LatestRelease="`egrep -A 12 \"Release notes\" Releases | sed 's/ *<.*> *//g' | egrep -v "^$" | sed -n '2p' | tr [A-Z] [a-z]`"
# LatestCodeName="`sed -e 's/<td>//g' -e 's/<br .>//' -e 's/ *<.*> *//g' Releases | egrep -v \"^$\" | egrep -B 4 \"^Long Term Support\" | head -1 | awk '{printf(\"%s\",$1);}'`"
# LatestRelease="`sed 's/ *<.*> *//g' Releases | egrep -v \"^$\" | egrep -B 3 \"^Long Term Support\" | head -1 | awk '{printf(\"%s\",$1);}'`"
##-
##-
##-
LatestCodeName="`sed -e 's/<td>//g' -e 's/<br .>//' -e 's/ *<.*> *//g' Releases | egrep -v \"^$\" | egrep -B 4 \"^Support for [0-9]* months \\\(until\" | head -1 | awk '{printf(\"%s\",$1);}' | tr [A-Z] [a-z]`"
LatestRelease="`sed 's/ *<.*> *//g' Releases | egrep -v \"^$\" | egrep -B 3 \"^Support for [0-9]* months \\\(until\" | head -1 | awk '{printf(\"%s\",$1);}'`"
cat <<EOF
using Yocto Project version: $LatestRelease as latest stable release.
- with CodeName: "$LatestCodeName" 
EOF


## Step 2: Install YoctoProject by cloning the repository.
cd ~/el
# { git clone -b $LatestRelease git://git.yoctoproject.org/poky.git; }
#	{ git clone git://git.yoctoproject.org/poky.git; }
[ -d poky ] && \
  { echo "theYoctoProject $(grep DISTRO_CODENAME ~/el/poky/meta-poky/conf/distro/poky.conf | sed -e 's/.* "//' -e 's/"$//') already installed."; }  || \
  { git clone -b $LatestCodeName git://git.yoctoproject.org/poky.git; }
cd ~/el/poky
[ -d meta-openembedded ] || \
  { git clone -b $LatestCodeName git://git.openembedded.org/meta-openembedded; }
[ -d meta-raspberrypi ] || \
  { git clone -b $LatestCodeName git://git.yoctoproject.org/meta-raspberrypi; }

## Step 3:
if egrep -i -q "ubuntu|debian" /proc/version
then
cat <<EOF
For Ubuntu - installing packages as below.
EOF
  
	sudo apt -y install \
  	gawk wget git-core diffstat unzip \
  	at build-essential chrpath cpio debianutils diffstat \
  	gcc gcc-multilib git iputils-ping libegl1-mesa liblz4-tool \
  	libsdl1.2-dev libsqlite3-dev mesa-common-dev perl \
  	python3 python3-git python3-jinja2 python3-passlib \
  	python3-pexpect python3-pip python3-subunit python-is-python3 \
  	socat sqlite3 texinfo unzip xterm xz-utils zstd 
  
else
cat <<EOF
For RHEL/Centos/Fedora -- installing packages as below.
EOF
  sudo dnf -y install \
  gawk make wget tar bzip2 gzip \
  at automake ccache chrpath cpio cpp diffstat \
  diffutils file findutils gawk gcc gcc-c++ git \
  git-core glibc-devel kernel-devel libsqlite3x \
  libsqlite3x-devel libstdc++-devel lz4 make mesa-libGL-devel \
  patch perl perl-bignum perl-Data-Dumper perl-File-Compare \
  perl-File-Copy perl-FindBin perl-locale perl-open \
  perl-Text-ParseWords perl-Thread-Queue python python3 \
  python3-devel python3-GitPython python3-jinja2 \
  python3-passlib python3-pexpect python3-pip \
  rpcgen SDL-devel socat sqlite-devel texinfo unzip \
  wget which xterm xz zstd 
	sudo dnf install -y make python3-pip which inkscape texlive-fncychap
  sudo pip3 install sphinx sphinx_rtd_theme pyyaml
fi
cat <<EOF
see - https://docs.yoctoproject.org/ref-manual/system-requirements.html 

Then, running ..
EOF
  # /usr/local/lib/python3.10
  PYTHON3=$(which python3)
  ${PYTHON3} -m pip install --upgrade pip
  pip install wheel pysqlite3

cat <<EOF
.. for more details
.. see https://docs.yoctoproject.org/ref-manual/system-requirements.html 

Done.
EOF
if egrep -i -q "ubuntu|debian" /proc/version
then
	:
else
  ##
  ##  - FEDORA 35/36 is unsupported. for honister.
  ##  - you will see
  ##  - WARNING: Host distribution "fedora-36" has not been validated with this version of the build system; you may possibly experience unexpected failures. It is recommended that you use a tested distribution.
  ##  so, 
  cat <<EOF
  ##  - FEDORA 35/36 is unsupported. for honister.
  ##  - so, using "FIXES"/commands as below, to ensure build.
EOF

  ## -- add prefix  "from pysqlite3._sqlite3" on line 27
  sudo su -c "sed 's/from *_sqlite3/from pysqlite3._sqlite3/' \
		/usr/local/lib/python3.10/sqlite3/dbapi2.py > \
		/usr/local/lib/python3.10/sqlite3/dbapi2.py.bak"
	sudo su -c "mv /usr/local/lib/python3.10/sqlite3/dbapi2.py.bak \
		/usr/local/lib/python3.10/sqlite3/dbapi2.py"

  ## -- comment WAL mode pragma on line 97 in ~/el/poky/bitbake/lib/bb/persist_data.py 
  sed '/cursor.execute.*WAL/s/^.*/# &/' ~/el/poky/bitbake/lib/bb/persist_data.py > \
		~/el/poky/bitbake/lib/bb/persist_data.py.bak 
	mv ~/el/poky/bitbake/lib/bb/persist_data.py.bak \
		~/el/poky/bitbake/lib/bb/persist_data.py 

  ## -- comment WAL mode pragma on line 72 in ~/el/poky/bitbake/lib/hashserv/__init__.py
  sed '/cursor.execute.*WAL/s/^.*/# &/' ~/el/poky/bitbake/lib/hashserv/__init__.py > \
		~/el/poky/bitbake/lib/hashserv/__init__.py.bak
	mv ~/el/poky/bitbake/lib/hashserv/__init__.py.bak \
		~/el/poky/bitbake/lib/hashserv/__init__.py
fi
