The bootloader’s job is to set up the system to a basic level 
(e.g. configure the memory controller so that DRAM is accessible) and load the kernel. 

Typically, the boot sequence is:
- ROM code that is stored on chip runs. It loads the Secondary Program Loader (SPL) into Static Random Access Memory (SRAM), which doesn’t require a memory controller. An SPL can be a stripped-down version of the full bootloader like u-boot. It is needed because of the limited SRAM size.
- The SPL sets up the memory controller so that DRAM can be accessed and does some other hardware configurations. Then, it loads the full bootloader into DRAM.
- The full bootloader then loads the kernel, the Flattened Device Tree (FDT) and optionally the initial RAM disk (initramfs) into DRAM. Once the kernel is loaded, the bootloader will hand over the control to it.
