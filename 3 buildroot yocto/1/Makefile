all: run

run:
	# perl needs perl-ExtUtils-MakeMaker
	if grep -q -i ubuntu /proc/version; \
	then \
		sudo su -c "apt -y install libextutils-makemaker-cpanfile-perl perl"; \
	else \
		sudo su -c "yum -y install perl-ExtUtils-MakeMaker perl"; \
	fi

	# see "https://deardevices.com/2019/04/18/how-to-crosscompile-raspi/"
	@echo ">>>>>    This step takes about 1min."
	./install_buildroot.sh
	@echo ">>>>>    buildroot installed to ~/el/buildroot"

clean:
	cd ~/el; time -p rm -fr buildroot*
