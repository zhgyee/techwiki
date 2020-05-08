# Introduction #

Add your content here.


# Details #

# 最小文件系统 #
编译一个测试程序， 使用GCC -static option 来静态编译
```
# arm-none-linux-gnueabi-gcc hello.c -static -o hello
```
Use the output file to create a root filesystem. The command cpio is used for this purpose. Execute the following command:
```
# echo hello | cpio -o --format=newc > rootfs
1269 blocks
```
Check the output file:
```
# file rootfs
rootfs: ASCII cpio archive (SVR4 with no CRC)
```