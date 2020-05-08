# 7420
请打开以下kernel选项后，查看一下系统带宽情况。
```
   Location:                                                                                                                                                                                 
     -> Device Drivers                                                                                                                                                                         
    -> Generic Dynamic Voltage and Frequency Scaling (DVFS) support (PM_DEVFREQ [=y])

   -> [ ]   SAMSUNG EXYNOS ppmu debug fs interface enable/disable
```
cat /sys/kernel/debug/exynos7420_bus
输出以下信息
```
total      read+write 38740126 6637683 MBps（这两个值是PPMU计数器的计数值，可以忽略）
 17.13% （MIF带宽的使用率）
total      read+write 38740126 5668081 MBps（这两个值是PPMU计数器的计数值，可以忽略）
 14.63% （INT带宽的使用率）
```
该结果是驱动中每隔100ms的统计结果，驱动会不停的统计。

一般情况下MIF带宽的使用率在50%以下是比较安全的，但在实时性要求比较高的系统中不一定。

1.ISP占用多少带宽
 
2.显示如果走Overlay，带宽是否够用？典型场景有三层SurfaceView(VR)+ActivityMainSurface+SurfaceView(CameraOverview)
该场景下增加一个SurfaceView(CameraOverview)后，算上preview和record的带宽消耗，假设preview buffer大小为2160*1200（可变），
record的大小为4096*2160@30fps（可变），增加的带宽大概为77*2160*1200*4*2 + 77*2160*1200*4*1.5 + 30*4096*2160*1.5*2 ≈ 2.7GB，
因此至少得增加2.7/25.6≈10.5%的带宽。
 
3.如果上层APP使用cameral数据作为纹理来使用，与VR场景叠加，带宽能否满足要求，GPU处理4K纹理性能最高有多少FPS？
该场景下增加一个CameraOverview的纹理后，算上preview和record的带宽消耗，假设preview buffer大小为2160*1200（可变），
record的大小为4096*2160@30fps（可变），增加的带宽大概为77*2160*1200*1.5 + 30*4096*2160*1.5*2 ≈ 1.1GB，
因此至少得增加1.1/25.6≈4.3%的带宽。
 
以上10.5%和4.3%的带宽值都是保守估计（GPU读取纹理等带宽消耗无法估算），加上最后的ISP的带宽值，系统总带宽很有可能已经超过
50%，超过50%后，系统性能会受到一定影响，需要看下实际的效果。