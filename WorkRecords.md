# Introduction #

Add your content here.


# Details #

[1](1.md)设置IP-----------------------------------
setenv serverip 10.157.186.254
setenv ipaddr 10.157.186.104
setenv netmask 255.255.254.0

[2](2.md)烧写fastboot-----------------------------------
mw.b 82000000 ff 80000;tftp 82000000 fastboot-burn.bin ;nand erase 0 100000;nand write 82000000 0 80000;

[3](3.md)烧写kernel-----------------------------------
mw.b 82000000 ff 400000;tftp 82000000 hi\_kernel.bin;nand erase 100000 400000;nand write 82000000 100000 400000

[4](4.md)烧写rootfs-----------------------------------
mw.b 82000000 ff 3c00000;tftp 82000000 rootfs.yaffs;nand erase 500000 3C00000
nand write.yaffs 82000000 500000


[5](5.md)设置bootargs-----------------------------------
setenv bootcmd 'nand read 0x82000000 0x100000 0x400000;bootm 0x82000000'
setenv bootargs 'mem=96M console=ttyAMA0,115200 root=/dev/mtdblock3 rootfstype=yaffs2 mtdparts=hinand:1M(boot),4M(kernel),60M(rootfs),1M(baseparam),1M(logo),20M(fastplay),-(others) mmz=ddr,0,0x86000000,160M  DmxPoolBufSize=0x200000 lpj=5996544'
setenv bootargs 'mem=96M console=ttyAMA0,115200 root=/dev/mtdblock3 rootfstype=yaffs2 mtdparts=hinand:1M(boot),4M(kernel),60M(rootfs),1M(baseparam),1M(logo),20M(fastplay),-(others) mmz=ddr,0,0x86000000,160M  DmxPoolBufSize=0x200000 lpj=5996544'
saveenv