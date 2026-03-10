# Originnal README file
see [Here](https://github.com/DCZYewen/eeweek-sdr/blob/master/README_ADI.md)。

# CLAIM!!!

Me, github [DCZYewen](https://github.com/DCZYewen), <big>CLAIMS THAT</big>:

Use of this device and firmware is at your own risk. The software is provided "AS IS" without warranty of any kind. The user is responsible for compliance with all applicable laws and regulations in their jurisdiction. The author assumes no liability for any damages or legal issues arising from the use of this firmware.

# Suggestions

1. Use Vivado 2022.2 and install it on `/tools/Xilinx`.
2. Use Ubuntu 20.04 if you are new to Linux, pro hackers never mind.
3. If you observe error on compiling kernel, plz try to install the libssl in blob directory.
4. High quality internet connection is in need during compilation, especially in buildroot, if you dont know what to do, download binary instead.
5. Copy the cross compile toolchain out of buildroot for further use, dont use the one comes with Vitis.
6. During the test procedure, you can bypass the LEAGAL INFO collection, by `export $SKIP_LEAGAL=1` or `make SKIP_LEAGAL=1`.
7. Using WSL or vmware is totally okay, but a cpu faster than Ryzen 5 5600 or Core i3 12100 or vCPU of at least 4 cores and memory larger than 4GB is recommended.

# Hints
1. If you accidentally destructed the out of factory firmware and its bootloader, do as follows:
```
1. Prepare a sdcard with less than 32GB and format it to FAT32.
2. Download the firmware recovery and copy the file to sdcard root directory.
3. Start the board in sdcard boot mode, during the uboot procedure press any key to stop autoboot.
4. In uboot shell, run `run flash_wipe` to erase the QSPI flash, then run `run flash_all` to write the firmware to QSPI again.
```
2. If the bootloader is still okay, just press the DFU button during bring up, flash the firmware under dfu like:
```
dfu-utils -D pluto.dfu -a 1
dfu-utils -D boot.dfu -a 0
dfu-utils -D uboot-env.dfu -a 3
```
3. Flash under Vivado Hardware Manager or Vitis XSCT via JTRG is also supported, use it if you like it.
4. The firmware is under a tempfs, all changes to file systemd will be discarded except for `/mnt/jffs2`. You can put your custom program and config files to `/mnt/jffs2`, see source code in `buildroot/board/pluto/S98autostart`.
5. If you wanted to use the SD card as a bulk device other than simulate it as a flash. Edit the buildroot on your own, super easy.


# Usage

1. Install all needed libraries and headers.

```
 sudo apt-get install git build-essential fakeroot libncurses5-dev libssl-dev ccache
 sudo apt-get install dfu-util u-boot-tools device-tree-compiler libssl1.0-dev mtools
 sudo apt-get install bc python cpio zip unzip rsync file wget
```
If libssl1.0-dev has no installation cadidate, see suggestion #3.

2. Export Vivado to enviornments.

`export VIVADO_SETTINGS=/tools/Xilinx/Vivado/2021.2/settings64.sh`

3. Do as follows:
```
make
make sdimg
bash collect_artifacts.sh
```
This will produce qspi and sdcard image in artifacts directory.