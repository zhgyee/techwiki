# dumpsys cpuinfo
## Load: 9.15 / 8.37 / 7.31
参考http://blog.scoutapp.com/articles/2009/07/31/understanding-load-averages

多核CPU上任务队列总数，如果是8核，如果队列数为8，则表示刚好满载，如果大于8则overload

On multi-processor system, the load is relative to the number of processor cores available. 
The "100% utilization" mark is 1.00 on a single-core system, 2.00, on a dual-core, 4.00 on a quad-core, etc.

Same with CPUs: a load of 1.00 is 100% CPU utilization on single-core box. On a dual-core box, a load of 2.00 is 100% CPU utilization.

# console对性能的影响
一般在实时性要求比较高的系统中，如果有内核打印log到console上，则会造成比较大的延迟，如exnoy 7420/8890上，串口打印时间平均有7ms，严重影响到系统的响应速度。

可以在release的时候将kernel config中*FIQ *CONSOLE相关的关闭，并将log level降低，输出到内存dmesg中，避免出现打印到串口的情况。

# TOP在big.Little下的含义(exynos 7420 example)
* x线程是绑定在小核上的，通过top看到的是小核上的使用率，不能与大核上的直接对比，CPU使用率只是一个时间统计，而大核的性能在同频率下是小核的2倍。
* 将x线程移到大核上，则CPU占用率只有1%不到。
* 小核的功耗远比大核低，所以小核高CPU使用率对功耗的贡献是不大的。

# Busybox Performance Monitoring
* iostat reports CPU, disk I/O, and NFS statistics.
* vmstat reports virtual memory statistics.
* mpstat reports processors statictics.

## iostat
```
iostat -c //Display only cpu statistics
iostat -d //Display only disk I/O statistics
iostat -n //Display only network statistics
iostat -m //Display I/O data in MB/second
iostat -p sda //Display I/O statistics only for a device
iostat 2 //Execute Every x seconds (for y number of times)
iostat 2 3 //To execute every 2 seconds for a total of 3 times, do the following.
```
## vmstat
vmstat by default will display the memory usage (including swap) 
```
vmstat -a //Display active and inactive memory
vmstat -f //Display number of forks since last boot
vmstat 2 10 //To execute every 2 seconds for 10 times, 
vmstat -m //Display slab info
vmstat -s // Display statistics in a table format
vmstat -S m //Display in MB
```
## mpstat
```
mpstat -A //displays all the information that can be displayed by the mpstat 
mpstat -P ALL //Display CPU statistics of individual CPU (or) Core
mpstat -I //中断相关统计
```
#ftrace && systrace
ftrace是linux提供的功能，systrace在ftrace的基础上提供可视化视图。
# perf 
perf使用更多是CPU的PMU计数器，PMU计数器是大部分CPU都有的功能，它们可以用来统计比如L1 Cache失效的次数，
分支预测失败的次数等。PMU可以在这些计数器的计数超过一个特定的值的时候产生一个中断，
这个中断，我们可以用和时钟一样的方法，来抽样判断系统中哪个函数发生了最多的Cache失效，分支预测失效等。

perf比起ftrace来说，最大的好处是它可以直接跟踪到整个系统的所有程序（而不仅仅是内核），
所以perf通常是我们分析的第一步，我们先看到整个系统的outline，然后才会进去看具体的调度，时延等问题
。而且perf本身也告诉你调度是否正常了，比如内核调度子系统的函数占用率特别高，我们可能就知道我们需要分析一下调度过程了。
* perf list列出perf可以支持的所有事件
* perf top可以动态收集和更新统计列表，和很多其他perf命令一样。它支持很多参数，但我们关键要记住两个参数：

```
sudo perf top -e branch-misses,cycles \\-e 指定跟踪的事件
sudo perf top -e 'cycles' -s comm,pid,dso \\ -s 指定按什么参数来进行分类
```
* perf-record用来启动一次跟踪，而perf-report用来输出跟踪结果。perf record不一定用于跟踪自己启动的进城，通过指定pid，可以直接跟踪固定的一组进城
```
sudo perf record -e 'cycles' -- myapplication arg1 arg2
sudo perf report
```
# net performance

[Understanding Application Performance on the Network](http://apmblog.dynatrace.com/2014/09/05/understanding-application-performance-on-the-network-conclusion/)

# graphic perf

With that in mind, here are some reasonable targets for Gear VR applications.
```
50 – 100 draw calls per frame
50k – 100k polygons per frame
As few textures as possible (but they can be large)
1 ~ 3 ms spent in script execution (Unity Update())
```
Bear in mind that these are not hard limits; treat them as rules of thumb.