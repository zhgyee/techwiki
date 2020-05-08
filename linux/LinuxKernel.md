# Introduction #

Add your content here.


# Details #

[proc](proc.md)

[make](make.md)

# process 0

1. 进程0是所有其他进程的祖先, 也称作idle进程或swapper进程.
2. 进程0是在系统初始化时由kernel自身从无到有创建.
3. 进程0的数据成员大部分是静态定义的，即由预先定义好的INIT_TASK, INIT_MM等宏初始化.
进程0的描述符init_task定义在arch/arm/kernel/init_task.c,由INIT_TASK宏初始化。 init_mm等结构体定义在include/linux/init_task.h内，为init_task成员的初始值,分别由对应的初始化宏如INIT_MM等初始化

Process 1
进程0最终会通过调用kernel_thread创建一个内核线程去执行init函数，这个新创建的内核线程即Process 1(这时还是共享着内核线程0的资源属性如地址空间等)。init函数继续完成剩余的内核初始化,并在函数的最后调用execve系统调用装入用户空间的可执行程序/sbin/init,这时进程1就拥有了自己的属性资源，成为一个普通进程(init进程)。至此，内核初始化和启动过程结束。下面就进入了用户空间的初始化，最后运行shell登陆界面。(注：Init进程一直存活，因为它创建和监控在操作系统外层执行的所有进程的活动。)

这段对进程0的描述引用自《Understanding The Linux Kernel - Third Edtion》
The ancestor of all processes, called process 0, the idle process, or, for historical reasons, the swapper process, is a kernel thread created from scratch during the initialization phase of Linux. This ancestor process uses the following statically allocated data structures (data structures for all other processes are dynamically allocated)