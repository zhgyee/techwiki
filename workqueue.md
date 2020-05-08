# Introduction
* work item
* workqueue：工作的集合。workqueue 和 work 是一对多的关系。
* worker/worker threads, worker 对应一个 work_thread() 内核线程。
* worker-pools:worker_pool 和 worker 是一对多的关系。
* pwq(pool_workqueue):中间人 / 中介，负责建立起 workqueue 和 worker_pool 之间的关系。workqueue 和 pwq 是一对多的关系，pwq 和 worker_pool 是一对一的关系。
![work queue relations](http://kukuruku.co/uploads/images/00/00/01/2015/03/04/x0d4dd4e8a1.png.pagespeed.ic.JEu-FaRReq.png)

  There are two types of worker-pools, one for normal work items and the other
for high priority ones, for each possible CPU and some extra
worker-pools to serve work items queued on unbound workqueues - the
number of these backing pools is dynamic.

  When a work item is queued to a workqueue, the target worker-pool is
determined according to the queue parameters and workqueue attributes
and appended on the shared worklist of the worker-pool.  For example,
unless specifically overridden, a work item of a bound workqueue will
be queued on the worklist of either normal or highpri worker-pool that
is associated to the CPU the issuer is running on.
![](http://kernel.meizu.com/images/posts/2016/08/wq_worker_pool.png)
![](http://kernel.meizu.com/images/posts/2016/08/wq_normal_wq_topology.png)

# API
alloc_workqueue(@name, @flags, @max_active)
## flags
* WQ_UNBOUND
  worker-pools which host workers which are not bound to any
specific CPU.  This makes the wq behave as a simple execution
context provider without concurrency management.  ** The unbound
worker-pools try to start execution of work items as soon as
possible. **  Unbound wq sacrifices locality but is useful for
the following cases.

* WQ_HIGHPRI
  Work items of a highpri wq are queued to the highpri
worker-pool of the target cpu.  Highpri worker-pools are
served by worker threads with elevated nice level.
  WQ_HIGHPRI usually set nice to -20

## max_active:

@max_active determines the maximum number of execution contexts per
CPU which can be assigned to the work items of a wq.  For example,
with @max_active of 16, at most 16 work items of the wq can be
executing at the same time per CPU.

Some users depend on the strict execution ordering of Single Thread wq.  The
combination of @max_active of 1 and WQ_UNBOUND is used to achieve this
behavior. Work items on such wq are always queued to the unbound
worker-pools and only one work item can be active at any given time thus
achieving the same ordering property as ST wq.

# Impl
## init
```
init_workqueues(void)
	init_worker_pool(pool)
	create_and_start_worker(pool)
		create_worker(pool);
			alloc_worker();
			worker->task = kthread_create_on_node(worker_thread, worker, pool->node, "kworker/%s", id_buf);
		start_worker(worker);
			worker_enter_idle(worker);
			wake_up_process(worker->task);
```

## alloc_workqueue
```
__alloc_workqueue_key()
	alloc_and_link_pwqs(wq)
		link_pwq(pwq);//normal wq
		apply_workqueue_attrs(wq, unbound_std_wq_attrs[highpri])//unbound workqueue
			alloc_unbound_pwq(wq, new_attrs);
				get_unbound_pool(attrs);//if no pool, create a new pool and start worker
				init_pwq(pwq, wq, pool);
```
## worker_thread
```
worker_thread()
	process_one_work(worker, work);
		worker->current_func(work);
```

# debugging
## name style
```
#ps | grep kworker
root      5     2     0      0     worker_thr 0000000000 S kworker/0:0H //normal high prio wq bound to cpu0
root      20    2     0      0     worker_thr 0000000000 S kworker/2:0	//normal wq bound to cpu2
root      390   2     0      0     worker_thr 0000000000 S kworker/0:1	//second wq bound to cup 0
root      799   2     0      0     worker_thr 0000000000 S kworker/u17:0//first unbound wq
```
## sysfs
create WQ with flag WQ_SYSFS to enable sysfs interface 
```
# ls /sys/bus/workqueue/devices/xxx/                    
cpumask
max_active
nice
numa
per_cpu
pool_ids
power
subsystem
uevent
```

## tracing
```
$ echo workqueue:workqueue_queue_work > /sys/kernel/debug/tracing/set_event
$ cat /sys/kernel/debug/tracing/trace_pipe > out.txt
```
# ref
[kernel workqueue doc](https://www.kernel.org/doc/Documentation/workqueue.txt)    
