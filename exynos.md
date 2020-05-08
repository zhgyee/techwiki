# 7420

# build
- Compile methods:
```
      #./build.sh avl7420 uboot
      #./build.sh avl7420 kernel
  
      #./build.sh avl7420 platform
     //compile all file
     #./build.sh avl7420 all
```
- Code commits:
```
      usage: (dependent tool: sudo apt-get install git-review python-pip)

      #git fetch origin master
      #git add FILE
      #git commit --amend
      #git review
```
- Document:

  ./docs/bsp
## kernel build
```
ROOT_DIR=~/workspace/exynos/7420/
OUT_DIR="$ROOT_DIR/out/target/product/$PRODUCT_BOARD"
OUT_HOSTBIN_DIR="$ROOT_DIR/vendor/samsung_slsi/script"
KERNEL_CROSS_COMPILE_PATH="$ROOT_DIR/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
DEVICE_DIR="$ROOT_DIR/device/samsung/avl7420/"
make  avl7420_truly_dualdisp_defconfig
make menuconfig
cp .config arch/arm64/configs/avl7420_truly_dualdisp_defconfig
./build.sh avl7420 kernel
make -C $ROOT_DIR/kernel M=`pwd` ARCH=arm64 CROSS_COMPILE=$KERNEL_CROSS_COMPILE_PATH modules

```
## image burning
```
sudo /home/zhgyee/workspace/exynos/7420/out/host/linux-x86/bin/fastboot flash partition_table out/target/product/avl7420/partition
sudo /home/zhgyee/workspace/exynos/7420/out/host/linux-x86/bin/fastboot flash bootloader ./bootable/uboot/sd_fuse/isee_image_signed/signed_bootloader
sudo /home/zhgyee/workspace/exynos/7420/out/host/linux-x86/bin/fastboot flash dtb kernel/arch/arm64/boot/exynos7420-avl7420-codegen.dtb
sudo /home/zhgyee/workspace/exynos/7420/out/host/linux-x86/bin/fastboot flash kernel kernel/arch/arm64/boot/Image
sudo /home/zhgyee/workspace/exynos/7420/out/host/linux-x86/bin/fastboot flash system out/target/product/avl7420/system.img
sudo /home/zhgyee/workspace/exynos/7420/out/host/linux-x86/bin/fastboot flash ramdisk out/target/product/avl7420/ramdisk-uboot.img 
sudo /home/zhgyee/workspace/exynos/7420/out/host/linux-x86/bin/fastboot flash userdata out/target/product/avl7420/userdata.img
sudo /home/zhgyee/workspace/exynos/7420/out/host/linux-x86/bin/fastboot flash cache out/target/product/avl7420/cache.img
sudo /home/zhgyee/workspace/exynos/7420/out/host/linux-x86/bin/fastboot reboot
```
#
```
make -f Makefile_aarch64 CROSS_COMPILE=$KERNEL_CROSS_COMPILE_PATH
```

# trace info

# sys control
```
adb shell cat /sys/class/devfreq/exynos7-devfreq-int/available_frequencies
100000 200000 266000 334000 400000 500000 510000 520000 530000 540000 550000 560000


adb shell cat /sys/class/devfreq/exynos7-devfreq-int/min_freq

adb shell echo 550000 > /sys/class/devfreq/exynos7-devfreq-int/min_freq

cd /sys/devices/system
adb shell 
echo 4 > /sys/devices/system/march-hotplug/cl0_min_num
echo 4 > /sys/devices/system/march-hotplug/cl1_min_num

echo 544 > /sys/devices/14ac0000.mali/clock

/sys/devices/system/cpu
cat /sys/devices/10060000.tmu/curr_temp
//0-bigcore 2-gpu
```
# 7420
```
while true; do cat /sys/devices/10060000.tmu/curr_temp && cat /sys/devices/14ac0000.mali/clock && cat /sys/class/devfreq/exynos7-devfreq-mif/cur_freq && cat /sys/class/devfreq/exynos7-devfreq-int/cur_freq && cat /sys/class/devfreq/exynos7-devfreq-disp/cur_freq && cat /sys/devices/system/cpu/online && cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_cur_freq && cat /sys/devices/14ac0000.mali/time_in_state /sys/devices/14ac0000.mali/utilization_stats; sleep 1; done
```
# 8890
```
while true; do cat /sys/devices/14ac0000.mali/clock && cat /sys/class/devfreq/17000010.devfreq_mif/cur_freq && cat /sys/class/devfreq/17000020.devfreq_int/cur_freq && cat /sys/class/devfreq/17000030.devfreq_disp/cur_freq && cat /sys/devices/system/cpu/online && cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_cur_freq && cat /sys/devices/14ac0000.mali/time_in_state /sys/devices/14ac0000.mali/utilization_stats; sleep 1; done
```
while true; do cat /sys/devices/10060000.tmu/curr_temp /sys/devices/14ac0000.mali/utilization_stats; sleep 1; done

# battery temp & current
```
adb shell dmesg  | grep healthd
cat /sys/class/power_supply/battery/uevent
```
# gpu profiling
```
while true; do cat /sys/devices/14ac0000.mali/time_in_state /sys/devices/14ac0000.mali/utilization_stats; sleep 1; done
while true; do cat /sys/devices/14ac0000.mali/utilization_stats; sleep 1; done

```

# service
```
setprop ctl.start boost_perf
device/samsung/avl7420/conf/init.avl7420.rc
```
# screen panel parameters
```
arch/arm64/boot/dts/avl7420-dsim-codegen.dtsi
```
# sensor
```
/dev/ivr0
cd /sys/class/invensense/mpu
echo 7 > gyro_enable //enable sensor
cat gyro_enable
cat raw_gyro //gyro data output

```
# bind core
```
taskset -ap 123
```

# graphic
```
setprop debug.sf.showfps 1
```
# RTLogs
```
adb shell setprop persist.sys.logcontrol 1
adb shell reboot
```

# 系统带宽消耗统计
配置内核
```
   Location:                                                                                                                                                                                 
     -> Device Drivers                                                                                                                                                                         
    -> Generic Dynamic Voltage and Frequency Scaling (DVFS) support (PM_DEVFREQ [=y])

   -> [ ]   SAMSUNG EXYNOS ppmu debug fs interface enable/disable

```
查看sys接口
```
cat /sys/kernel/debug/exynos7420_bus

total      read+write 38740126 6637683 MBps（这两个值是PPMU计数器的计数值，可以忽略）
 17.13% （MIF带宽的使用率）
total      read+write 38740126 5668081 MBps（这两个值是PPMU计数器的计数值，可以忽略）
 14.63% （INT带宽的使用率）
```
 
该结果是驱动中每隔100ms的统计结果，驱动会不停的统计。

一般情况下MIF带宽的使用率在50%以下是比较安全的，但在实时性要求比较高的系统中不一定。