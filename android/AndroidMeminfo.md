# dumpsys meminfo
* GL mtrack is driver-reported GL memory usage. It's primarily the sum of GL texture sizes, GL command buffers, fixed global driver RAM overheads, etc.
* EGL mtrack is gralloc memory usage. It's primarily the sum of the SurfaceView/TextureView.
* In general, be concerned with only the Pss Total（占比内存） and Private Dirty(独占内存) columns. 
* In some cases, the Private Clean and Heap Alloc columns also offer interesting data.
* zram 交换出去的内存
* ksm 页面合并信息
* 按oom_adj分类和排序

# dumpsys procstats
procstats makes it possible to see how your app is behaving over time—including how long it runs in the background and how much memory it uses during that time.

To get application memory usage stats over the last three hours, in human-readable format, run the following command:

```
adb shell dumpsys procstats --hours 3
```
minPSS-avgPSS-maxPSS/minUSS-avgUSS-maxUSS

# procrank
procrank will show you a quick summary of process memory utilization. By default, it shows Vss, Rss, Pss and Uss, and sorts by Vss. However, you can control the sorting order.

procrank source is included in system/extras/procrank, and the binary is located in /system/xbin on an android device.

* Vss = virtual set size
* Rss = resident set size
* Pss = proportional set size
* Uss = unique set size

In general, the two numbers you want to watch are the Pss and Uss (Vss and Rss are generally worthless, because they don't accurately reflect a process's usage of pages shared with other processes.)

Uss is the set of pages that are unique to a process. This is the amount of memory that would be freed if the application was terminated right now.
Pss is the amount of memory shared with other processes, accounted in a way that the amount is divided evenly between the processes that share it. This is memory that would not be released if the process was terminated, but is indicative of the amount that this process is "contributing"

# procmem
显示map所占内存大小
Another tried and tested tool: shows Vss, Rss, etc for each mapping of a single process

# Tuning Android for low RAM
* Tune Activity manager
* Tune Dalvik
* Tune Apps

# Tuning Linux for low RAM
* KSM
* Swap to compressed RAM
* Tune ION carveout


