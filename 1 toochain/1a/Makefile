all: rpi

rpi:
	@echo "see \"https://github.com/crosstool-ng/crosstool-ng/issues/1337\" for the zlib download issue"
	sleep 12
	./configure-Crosstool-ng_rpi.sh | tee crosstool.out
	
scp:
	scp -P 2222 rpi*-helloc* pi@localhost:el/Chapter_02/Examples/1a

clean:
	rm -f hello helloc hellocpp rpi*-helloc rpi*-hellocpp
