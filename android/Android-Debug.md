# 线程信息
ANR 发生时 AMS 会通过 ps -t 命令输出线程的状态信息,需要注意分析进程是否启动了数量异常的子线程，发生 ANR 时各个应用的内存使用量;是否启动了一些异常的进程。
此外还应注意线程的运行状态,其中 S、R 都是 PS 中常见的正常线程状态。需要特别注意的是 D 状态,在 D 状态说明进程处于不可中断的睡眠状态,此时它不会响应任何外部信号,
甚至无法用 Kill 杀死进程。处于此状态的线程通常是在等待 I/O,比如磁盘 I/O、网络 I/O 或者外设 I/O。线程短时间处于 D 状态是正常现象,但是在 I/O 瓶颈较严重的手机上如果应用连续几秒或者更长时间都处于 D 状态无法响应外部信号,就会导致 ANR。

线程状态 | 含义
------- | --------
S | 可中断的睡眠
R | 运行或就绪状态
D | 不可中断的睡眠
Z | 退出状态,作为僵尸进程等待回收
X | 退出状态,即将被回收
T | 暂停或跟踪状态

# dump process info
The easiest way is with DDMS, or the ADT plugin in Eclipse. See http://developer.android.com/tools/debugging/ddms.html for basic instructions. In short, go into the Device view, select the application you're interested in, make sure thread updates are enabled, and switch to the Threads view. You will get a live-updated list of threads in that process. Double-clicking on a thread will grab a snapshot of the current stack state.
```
% adb shell ps | grep android.calendar
u0_a6     2596  127   912804 48296 ffffffff b6f62c10 S com.google.android.calendar
[ 2596 is the process ID ]
% adb shell kill -3 2596
```
The logcat output will say something like:

I/dalvikvm( 2596): Wrote stack traces to '/data/anr/traces.txt'

# 使用DDMS中的native heap检查Android native内存泄露

* 检查手机上目录system/lib（system/lib64）下存在libc_malloc_debug_leak.so、libc_malloc_debug_qemu.so（eng或者user-debug版本自带）
* setprop libc.debug.malloc 1（android7.0以后设置新属性 ：setprop libc.debug.malloc.options backtrace https://android.googlesource.com/platform/bionic/+/master/libc/malloc_debug/README.md）。这里有四种prop可以设置，1是mem leak，5和10是内存越界，20是虚拟机。可悲的是5和10并没有被libc_malloc_debug库完美地支持，所以只有1好用
* adb shell stop, start （不要手动关机重启，否则上一步设置的属性值会丢失），getprop libc.debug.malloc查看结果
* 在ddms.cfg文件最后增加一行native=true并save。ddms.cfg位于.android目录下。(建议在官网上单独下载SDK工具包，使用里面的ddms)
* 打开ddms选择Native Heap页面，点击snapshot按钮。snapshot的过程有点慢。最后能看到每个so占用了多少内存以及百分比。过一段时间snapshot一次就能看到每个so的趋势了。
* 分析。snapshot显示了分配内存的地址（记做addressA），这个地址是RAM地址，不是so的相对地址。为了得到相对地址，需要ps一下，找到你的pid，然后cat /proc/pid/maps,找到so的起始地址(记做addressB)。然后拿addressA - addressB，得到相对地址，用addr2line定位到哪一处调用。或者使用objdump -dS libXXX.so > XXX.dump，把so反编译出来，分析XXX.dump，找到相对地址的调用位置（lib64下so：prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9/bin/x86_64-linux-android-addr2line ）