all: run 

clean:
	rm -fr ~/crosstool-ng ~/xtools

run:
	@echo "Note following install takes about 2 minutes to run".
	export HOST_CPU_C_ABI_32BIT=no
	time -p ./install-ct-ng.sh
	echo "now sleeping 10 .. and thereafter it will show that the \"man 1 ct-ng\" cmd works."
	sleep 10
	MANPATH="$$MANPATH:$$HOME/el/crosstool-ng/share/man" man 1 ct-ng | head -60 
	sleep 2 
	@echo "also export MANPATH=\"\$$MANPATH:$$HOME/el/crosstool-ng/share/man\" to your bashrc"
