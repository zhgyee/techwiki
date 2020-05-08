# Introduction #

Add your content here.


# Compile #
  1. Install dependence packages
```
$ sudo apt-get install autoconf autogen \
  automake autotools-dev binutils fakeroot \
  git-core g++ libsdl1.2-dev make \
  sbrsh subversion
```
  1. Downland source and compile
```
$ cd $HOME/sbox2/src
$ git clone git://git.savannah.nongnu.org/qemu.git
$ cd qemu
$ ./configure --prefix=$HOME/sbox2/bin/qemu
$ make
$ make install
```

# Run #
##  直接运行程序 ## 
```
arm-linux-gcc test_qemu.c --static -o test_qemu
qemu-arm ./test_qemu
```
##  运行内核 ## 
```
qemu-system-arm -M versatilepb -m 128M -kernel arch/arm/boot/uImage
```
如何看到内核输出：
  * 按ctrl+alt+3才能看到内核输出，ctrl+alt+2是qemu控制终端， ctrl+alt+1是图形终端
  * -nographic      disable graphical output and redirect serial I/Os to console. When using -nographic, press 'ctrl-a h' to get some help. ctral-a x 退出，类似于minicom
##  带文件系统 ## 
  * 首先建立最小文件系统[rootfs](rootfs.md)
  * 带文件系统运行
```
qemu-system-arm -M versatilepb -m 128M -kernel arch/arm/boot/uImage -initrd rootfs -append "root=/dev/ram rdinit=/hello"
```
##  带boot运行 ## 
  * 建立最小[Boot](Boot.md)
  * 在qemu中运行
```
$ qemu-system-arm -M versatilepb -nographic -kernel output.bin
```
##  运行uboot ## 
  * 编译[uboot](uboot.md)
  * 将uboot和app制作成镜像，并运行
```
#cat u-boot.bin test.uimg > flash.bin
# qemu-system-arm -M versatilepb -nographic -kernel flash.bin
```
  * 计算出app在flash中的地址，启动app
```
Versatile # bootm 0x21C68
```