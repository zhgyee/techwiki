# camera
## dump in HAL
```
setprop  "persist.camera.dumpimg"
#define QCAMERA_DUMP_FRM_PREVIEW    1
#define QCAMERA_DUMP_FRM_VIDEO      (1<<1)
#define QCAMERA_DUMP_FRM_SNAPSHOT   (1<<2)
#define QCAMERA_DUMP_FRM_THUMBNAIL  (1<<3)
#define QCAMERA_DUMP_FRM_RAW        (1<<4)
#define QCAMERA_DUMP_FRM_JPEG       (1<<5)

#define QCAMERA_DUMP_FRM_MASK_ALL    0x000000ff 
```
## dump in ISP
```
setprop  "persist.camera.isp.dump" 参数如下： 

    Usage: To enable dumps
    Preview: adb shell setprop persist.camera.isp.dump 2
    Snapshot: adb shell setprop persist.camera.isp.dump 8
    Video: adb shell setprop persist.camera.isp.dump 16
    To dump 10 frames again, just reset prop value to 0 and then set again 
```

# 获最温度、频率等信息
```
#!/bin/sh
echo "read bettery info"
echo "====================================================="`date`"======================================================================================" >> /sdcard/system.info
while true; do \
echo "gpu clk: " `cat /sys/class/kgsl/kgsl-3d0/gpuclk` "gpu usage: " `cat /sys/class/kgsl/kgsl-3d0/devfreq/gpu_load` "current:" `cat /sys/class/power_supply/battery/current_now` "temp:" `cat /sys/class/thermal/thermal_zone5/temp` | tee -a /sdcard/system.info; \ 
sleep 1;\ 
done;
```