# cpuctrl
在Android中也存在cgroups，但涉及到CPU的目前只有两个，一个是apps，路径为/dev/cpuctl/apps。另一个是bg_non_interactive，路径为/dev/cpuctl/apps/bg_non_interactive
 
1、cpu.share
cpu.share文件中保存了整数值，用来设置cgroup分组任务获得CPU时间的相对值。举例来说，cgroup A和cgroup B的cpu.share值都是1024，那么cgroup A 与cgroup B中的任务分配到的CPU时间相同，如果cgroup C的cpu.share为512，那么cgroup C中的任务获得的CPU时间是A或B的一半。
 
apps下的cpu.share 值为1024
root@htc_m8tl:/dev/cpuctl/apps # cat cpu.shares
1024
 
bg_non_interactive下的cpu_share值为52
root@htc_m8tl:/dev/cpuctl/apps/bg_non_interactive # cat cpu.shares
52
 
从上面的数据可以看出，apps分组与bg_non_interactive分组cpu.share值相比接近于20:1。由于Android中只有这两个cgroup，也就是说apps分组中的应用可以利用95%的CPU，而处于bg_non_interactive分组中的应用则只能获得5%的CPU利用率。
 
2、cpu.rt_period_us与cpu.rt_runtime_us
cpu.rt_period_us：主要是用来设置cgroup获得CPU资源的周期，单位为微秒。 cpu.rt_runtime_us：主要是用来设置cgroup中的任务可以最长获得CPU资源的时间，单位为微秒。设定这个值可以访问某个cgroup独占CPU资源。最长的获取CPU资源时间取决于逻辑CPU的数量。比如cpu.rt_runtime_us设置为200000（0.2秒），cpu.rt_period_us设置为1000000（1秒）。在单个逻辑CPU上的获得时间为每秒为0.2秒。 2个逻辑CPU，获得的时间则是0.4秒。
 
apps分组下的两个配置的值
root@htc_m8tl:/dev/cpuctl/apps # cat cpu.rt_period_us
1000000
root@htc_m8tl:/dev/cpuctl/apps # cat cpu.rt_runtime_us
800000
即单个逻辑CPU下每一秒内可以获得0.8秒的执行时间。
 
bg_non_interactive分组下的两个配置的值
 
root@htc_m8tl:/dev/cpuctl/apps/bg_non_interactive # cat cpu.rt_period_us
1000000
root@htc_m8tl:/dev/cpuctl/apps/bg_non_interactive # cat cpu.rt_runtime_us
700000
即单个逻辑CPU下每一秒可以获得0.7秒的执行时间。

# cpuset
首先要在内核中打开cgroup/cpuset支持，menuconfig路径为：
`General setup-->Control Group support-->Cpuset support`

Here is a quick example of how to use cpuset to reserve one cpu for your real-time process on a 4 cpu machine:
```
# mkdir /dev/cpuset/rt0
# echo 0 > /dev/cpuset/rt0/cpus
# echo 0 > /dev/cpuset/rt0/mems
# echo 1 > /dev/cpuset/rt0/cpu_exclusive
# echo $RT_PROC_PID > /dev/cpuset/rt0/tasks
# mkdir /dev/cpuset/system
# echo 1-3 > /dev/cpuset/system/cpus
# echo 0 > /dev/cpuset/system/mems
# echo 1 > /dev/cpuset/system/cpu_exclusive
# for pid in $(cat /dev/cpuset/tasks); do /bin/echo $pid > /dev/cpuset/system/tasks; done
```
cpu_exclusive 为独占CPU标志，该group独占相应的CPU

A process may be added to a cpuset *(automatically removing it from the cpuset that 
              previously contained it)* by writing its PID to that cpuset's
              tasks file (with or without a trailing newline).

# irqbalance
要让中断的CPU Affinity起作用，irq balance 服务必须被关闭。但这样中断负载平衡就被打断，需要手工指定在规定的若干个CPU核心上负责中断平衡   
Then make sure that the interrupts are not automatically balanced by the irqbalance daemon. This daemon is started from the irqbalance init script. To disable once do:
`# /etc/init.d/irqbalance stop`
To disable after next reboot do:
`# chkconfig irqbalance off`
After this you can change the CPU affinity mask of each interrupt by doing:
`# echo hex_mask > /proc/irq/<irq_number>/smp_affinity`

# sched_setscheduler


# ref
[CPU shielding using /proc and /dev/cpuset](https://rt.wiki.kernel.org/index.php/CPU_shielding_using_/proc_and_/dev/cpuset)
[Documentation/cpusets.txt](https://lwn.net/Articles/127936/)
[linux组调度浅析 cgroupd 多个进程组 多个cgroup](http://m.blog.csdn.net/article/details?id=39078139)