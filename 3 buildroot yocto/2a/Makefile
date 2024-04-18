all: run

## default RPi configs available
##
##    raspberrypi0-2w-64
##    raspberrypi0-2w
##    raspberrypi0
##    raspberrypi0-wifi
##    raspberrypi2
##    raspberrypi3-64
##    raspberrypi3
##    raspberrypi4-64
##    raspberrypi4
##    raspberrypi-armv7
##    raspberrypi-armv8
##    raspberrypi-cm3
##    raspberrypi-cm
##    raspberrypi
##

run:
	more README.txt
	time ./configure-rpi.sh raspberrypi4-64 | tee rpi_configure.log

clean:
