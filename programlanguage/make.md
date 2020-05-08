# Introduction #

Add your content here.


# Details #
```
make ARCH=arm CROSS_COMPILE=arm- xxx_defconfig 将xxx_defconfig 拷贝为.config
make ARCH=arm CROSS_COMPILE=arm- menuconfig 配置选项
make ARCH=arm CROSS_COMPILE=arm- uImage 编译内核
make ARCH=arm CROSS_COMPILE=arm- modules 编译模块
make -C $(LINUX_DIR) ARCH=arm CROSS_COMPILE=arm- M=$(CURDIR) modules 在内核外编译模块
```