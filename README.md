# Originnal README file
see [Here](https://github.com/DCZYewen/eeweek-sdr/blob/master/README_ADI.md)。

# Suggestions

1. Use Vivado 2022.2 and install it on /tools/Xilinx .
2. Use Ubuntu 20.04 if you are new to Linux, pro hackers never mind.
3. If you observe error on compiling kernel, plz try to install the libssl in blob directory.
4. High quality internet connection is in need during compilation, especially in buildroot, if you dont know what to do, download binary instead.
5. Copy the cross compile toolchain out of buildroot for further use, dont use the one comes with Vitis.

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