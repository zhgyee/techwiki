# gpu信息
## 高通平台
```
cat   /sys/class/kgsl/kgsl-3d0/gpuclk && cat   /sys/class/kgsl/kgsl-3d0/devfreq/gpu_load
```
## 三星平台
```
#!/bin/sh
echo "read bettery info"
echo "====================================================="`date`"======================================================================================" >> /sdcard/system.info
while :; do
echo "cpu-onlines:" `cat /sys/devices/system/cpu/online` "little-cpu-freq:"`cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq` \
 "big-cpu-freq:"`cat /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_cur_freq` "big-cpu-temp:"`cat /sys/class/thermal/thermal_zone0/temp` \
 "gpu-clock:"`cat /sys/devices/platform/13900000.mali/clock` \
 "gpu-utilization:"`cat /sys/devices/platform/13900000.mali/utilization`  "current_now:"`cat /sys/class/power_supply/battery/current_now` \
 "voltage_now:"`cat /sys/class/power_supply/battery/voltage_now` "capacity:"`cat /sys/class/power_supply/battery/capacity` | tee -a /sdcard/system.info
 sync;
sleep 1
done
```

# 电池信息
```
cat /sys/class/power_supply/battery/current_now
```