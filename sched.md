# sched_setscheduler
设置进程或线程的调度器
```
#include <sched.h>

int sched_setscheduler(pid_t pid, int policy,
					  const struct sched_param *param);

int sched_getscheduler(pid_t pid);
```
policy的类型：
* SCHED_OTHER the standard round-robin time-sharing policy;
* SCHED_IDLE for running very low priority background jobs.
* SCHED_BATCH 针对具有batch风格（批处理）进程的调度策略，适合后台CPU消耗型的任务

For each of the above policies, param->sched_priority must be 0.
* SCHED_FIFO    a first-in, first-out policy; 按照优先级顺序执行，会抢占其它任务，如果不主动让出CPU，则会一直占用
* SCHED_RR      a round-robin policy.跟SCHED_FIFO类似，不过可以设定最大运行时间片

For each of the above policies, param->sched_priority specifies a scheduling priority for the thread.  This is a number in the range returned by calling sched_get_priority_min(2) and sched_get_priority_max(2) with the specified policy.  On Linux, these system calls return, respectively, 1 and 99.

**用户态设置RT Sched policy需要有root权限，在android上可以通过binder server来实现。**    
**内核线程可以通过sched_setscheduler_nocheck()来设置**

# setpriority
设置SCHED_OTHER调度器的nice值
```
int setpriority(int which, int who, int prio);
```
第一个参数which可选值为PRIO_PROGRESS,表示设置进程；PRIO_PGROUP表示设置进程组；PRIO_USER表示user。    
第二个参数who，根据第一个参数的不同，分别指向进程ID；进程组ID和user id。    
第三个参数学名叫nice值，从-20到19。是优先级的表示，越大表明越nicer，优先级越低。    
