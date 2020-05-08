# vsync
kernel/drivers/video/exynos/decon/decon-int_drv.c
```
diff --git a/kernel/drivers/video/exynos/decon/decon-int_drv.c b/kernel/drivers/video/exynos/decon/decon-int_drv.c
index 8e7b2bd..9024ce3 100755
--- a/kernel/drivers/video/exynos/decon/decon-int_drv.c
+++ b/kernel/drivers/video/exynos/decon/decon-int_drv.c
@@ -21,6 +21,7 @@
 #include <linux/exynos_iovmm.h>
 #include <linux/of_address.h>
 #include <linux/clk-private.h>
+#include <linux/sched.h>
 
 #include <media/v4l2-subdev.h>
 
@@ -923,6 +924,10 @@ int decon_fb_config_eint_for_te(struct platform_device *pdev, struct decon_devic
 static int decon_wait_for_vsync_thread(void *data)
 {
        struct decon_device *decon = data;
+       struct sched_param param;
+
+       param.sched_priority = 50;
+       sched_setscheduler_nocheck(get_current(), SCHED_RR, &param);
 
        while (!kthread_should_stop()) {
                ktime_t timestamp = decon->vsync_info.timestamp;

```
# workqueue
```
diff --git a/kernel/kernel/workqueue.c b/kernel/kernel/workqueue.c
index 1b2df27..e947575 100644
--- a/kernel/kernel/workqueue.c
+++ b/kernel/kernel/workqueue.c
@@ -1742,6 +1742,15 @@ static struct worker *create_worker(struct worker_pool *pool)
        set_user_nice(worker->task, pool->attrs->nice);
        set_cpus_allowed_ptr(worker->task, pool->attrs->cpumask);
 
+       /*
+        * Set unbound worker to RT thread for VR boost
+        */
+       if (pool->cpu < 0 && pool->attrs->nice < 0) {
+               struct sched_param param;
+               param.sched_priority = 20;
+               sched_setscheduler_nocheck(worker->task, SCHED_FIFO, &param);
+       }
+
        /* prevent userland from meddling with cpumask of workqueue workers */
        worker->task->flags |= PF_NO_SETAFFINITY;
```
# cpuset & cgroup enable
```
diff --git a/kernel/arch/arm64/configs/avl7420_truly_dualdisp_defconfig b/kernel/arch/arm64/configs/avl7420_truly_dualdisp_defconfig
index 8cc3e6b..2adfccd 100755
--- a/kernel/arch/arm64/configs/avl7420_truly_dualdisp_defconfig
+++ b/kernel/arch/arm64/configs/avl7420_truly_dualdisp_defconfig
@@ -105,7 +105,8 @@ CONFIG_CGROUPS=y
 CONFIG_CGROUP_DEBUG=y
 CONFIG_CGROUP_FREEZER=y
 # CONFIG_CGROUP_DEVICE is not set
-# CONFIG_CPUSETS is not set
+CONFIG_CPUSETS=y
+CONFIG_PROC_PID_CPUSET=y
```

# init.rc
device/samsung/avl7420/conf/init.avl7420.rc
```
diff --git a/device/samsung/avl7420/conf/init.avl7420.rc b/device/samsung/avl7420/conf/init.avl7420.rc
index 814be74..295de1b 100755
--- a/device/samsung/avl7420/conf/init.avl7420.rc
+++ b/device/samsung/avl7420/conf/init.avl7420.rc
@@ -550,6 +550,7 @@ service yamaha537 /system/bin/yamaha537
     user root
     group system input
     class main
+    writepid /dev/cpuset/system-background/tasks
 
  #ad reg op sock
 service ad_daemon /system/bin/ad_daemon
@@ -564,6 +565,7 @@ service logkit /system/bin/logkit /sdcard/RTLogs/  50  0
     socket logkit stream 666 system system
 #    disabled
     oneshot
+    writepid /dev/cpuset/system-background/tasks
 
 #on boot
  #   start logkit
@@ -596,3 +598,9 @@ service march_hotplug /system/bin/march_hotplug
 on property:ro.debuggable=1
     write /sys/module/kgdboc/parameters/kgdboc ttyFIQ1
     write /sys/module/fiq_debugger/parameters/kgdb_enable 1
+
+service vrservice /system/bin/vrserver
+    class core
+    user root
+    writepid /dev/cpuset/system-background/tasks
+
```
system/core/rootdir/init.rc
```
diff --git a/device/samsung/avl7420/conf/init.avl7420.rc b/device/samsung/avl7420/conf/init.avl7420.rc
index 814be74..295de1b 100755
--- a/device/samsung/avl7420/conf/init.avl7420.rc
+++ b/device/samsung/avl7420/conf/init.avl7420.rc
@@ -550,6 +550,7 @@ service yamaha537 /system/bin/yamaha537
     user root
     group system input
     class main
+    writepid /dev/cpuset/system-background/tasks
 
  #ad reg op sock
 service ad_daemon /system/bin/ad_daemon
@@ -564,6 +565,7 @@ service logkit /system/bin/logkit /sdcard/RTLogs/  50  0
     socket logkit stream 666 system system
 #    disabled
     oneshot
+    writepid /dev/cpuset/system-background/tasks
 
 #on boot
  #   start logkit
@@ -596,3 +598,9 @@ service march_hotplug /system/bin/march_hotplug
 on property:ro.debuggable=1
     write /sys/module/kgdboc/parameters/kgdboc ttyFIQ1
     write /sys/module/fiq_debugger/parameters/kgdb_enable 1
+
+service vrservice /system/bin/vrserver
+    class core
+    user root
+    writepid /dev/cpuset/system-background/tasks
+
zhgyee@zhgyee-pc:~/workspace/exynos/7420$ git diff 9291c75 system/core/rootdir/init.rc
diff --git a/system/core/rootdir/init.rc b/system/core/rootdir/init.rc
index c87766f..95dd0dd 100755
--- a/system/core/rootdir/init.rc
+++ b/system/core/rootdir/init.rc
@@ -147,7 +147,7 @@ on init
     # this ensures that the cpusets are present and usable, but the device's
     # init.rc must actually set the correct cpus
     mkdir /dev/cpuset/foreground
-    write /dev/cpuset/foreground/cpus 0
+    write /dev/cpuset/foreground/cpus 2-7
     write /dev/cpuset/foreground/mems 0
     mkdir /dev/cpuset/foreground/boost
     write /dev/cpuset/foreground/boost/cpus 0
@@ -160,7 +160,7 @@ on init
     # little cores, not on bigs
     # to be used only by init, so don't change system-bg permissions
     mkdir /dev/cpuset/system-background
-    write /dev/cpuset/system-background/cpus 0
+    write /dev/cpuset/system-background/cpus 1-3
     write /dev/cpuset/system-background/mems 0
 
     # change permissions for all cpusets we'll touch at runtime
@@ -172,11 +172,13 @@ on init
     chown system system /dev/cpuset/foreground/tasks
     chown system system /dev/cpuset/foreground/boost/tasks
     chown system system /dev/cpuset/background/tasks
+
     chmod 0664 /dev/cpuset/foreground/tasks
     chmod 0664 /dev/cpuset/foreground/boost/tasks
     chmod 0664 /dev/cpuset/background/tasks
     chmod 0664 /dev/cpuset/tasks
-
+    chmod 0664 /dev/cpuset/foreground/cpus
+    chmod 0664 /dev/cpuset/background/cpus
 
     # qtaguid will limit access to specific data based on group memberships.
     #   net_bw_acct grants impersonation of socket owners.
@@ -621,6 +623,7 @@ service vold /system/bin/vold \
     socket vold stream 0660 root mount
     socket cryptd stream 0660 root mount
     ioprio be 2
+    writepid /dev/cpuset/system-background/tasks
 
 service netd /system/bin/netd
     class main
@@ -662,6 +665,7 @@ service media /system/bin/mediaserver
     user media
     group audio camera inet net_bt net_bt_admin net_bw_acct drmrpc mediadrm media_rw
     ioprio rt 4
+    writepid /dev/cpuset/system-background/tasks
 
 # One shot invocation to deal with encrypted volume.
 service defaultcrypto /system/bin/vdc --wait cryptfs mountdefaultencrypted
@@ -692,6 +696,7 @@ service gatekeeperd /system/bin/gatekeeperd /data/misc/gatekeeper
 service installd /system/bin/installd
     class main
     socket installd stream 600 system system
+    writepid /dev/cpuset/system-background/tasks
 
 service flash_recovery /system/bin/install-recovery.sh
     class main
@@ -712,6 +717,7 @@ service mtpd /system/bin/mtpd
     group vpn net_admin inet net_raw
     disabled
     oneshot
+    writepid /dev/cpuset/system-background/tasks
 
 service keystore /system/bin/keystore /data/misc/keystore
     class main
```
# arch hot plug
device/samsung/avl7420/power/march_hotplug.cpp
```
 static unsigned int exynos_get_cluster1_stay_cnt(void)
 {
        status_type status = kernel_data.curr_status;
@@ -171,6 +194,7 @@ void *march_hotplug_monitor(void *data)
     ALOGV("%s: log_onoff = %d\n", __func__, kernel_data.log_onoff);
 
        cluster1_stay_cnt = exynos_get_cluster1_stay_cnt();
+    lcd_is_on = kernel_data.lcd_is_on;
 
     do {
         err = poll(&fds, 1, -1);
@@ -193,6 +217,12 @@ void *march_hotplug_monitor(void *data)
             } else {
                 ALOGE("Can't calculate next hotplug.\n");
             }
+            if (!lcd_is_on && kernel_data.lcd_is_on ) {
+                ALOGD("lcd state:%d, setup cpuset", kernel_data.lcd_is_on);
+                sysfs_write("/dev/cpuset/foreground/cpus", "2-7");
+                sysfs_write("/dev/cpuset/system-background/cpus", "1-3");
+            }
+            lcd_is_on = kernel_data.lcd_is_on;
 
            fds.revents = 0;
         }
@@ -225,4 +255,4 @@ int main(int /*argc*/, char ** /*argv*/) {
     load_configuration();
     march_hotplug_init();
     return 0;
-}
\ No newline at end of file
+}

```

# vrserver run as root 
```
+int VRService::setThreadAttr(int pid, int target, int prio, int sched_policy) {
+       cpu_set_t cpu_set;
+       int cpu_num = IVR_CPU_NB;
+       struct sched_param param;
+
+       if (target >= IVR_CPU_NB) {
+               ALOGE("invalid target cpu:%d", target);
+               return -1;
+       }
+
+       ALOGD("setup crgp info, pid:%d, core:%d, prio:%d, sched:%d",
+                       pid, target, prio, sched_policy);
+
+//     if (set_cpuset_policy(pid, SP_VR_APP)) {
+//             ALOGE("set_cpuset_policy failed");
+//             return -1;
+//     }
+//     if (set_sched_policy(pid, SP_VR_APP)) {
+//             ALOGE("set_sched_policy failed");
+//             return -1;
+//     }
+
+       sched_getaffinity(pid, sizeof(cpu_set), &cpu_set);
+       ALOGD("orig cpu_set[0]=0x%08lx, pid:%d", cpu_set.__bits[0], pid);
+       CPU_ZERO(&cpu_set);
+       CPU_SET(target, &cpu_set);
+       sched_setaffinity(pid, sizeof(cpu_set), &cpu_set);
+       sched_getaffinity(pid, sizeof(cpu_set), &cpu_set);
+       ALOGD("new cpu_set[0]=0x%08lx, pid:%d", cpu_set.__bits[0], pid);
+       setpriority(PRIO_PROCESS, pid, prio);
+
+       int expected_policy = sched_policy_map[sched_policy];
+       memset(&param, 0, sizeof(param));
+
+       if (expected_policy > SCHED_OTHER) {
+               param.sched_priority = sched_get_priority_min(expected_policy) - prio;
+       } else {
+               param.sched_priority = 0;
+       }
+
+       sched_setscheduler(pid, expected_policy, &param);
+       int result_policy = sched_getscheduler(pid);
+       if (result_policy != expected_policy) {
+               ALOGE("sched_setscheduler for %d, failed, expected:%d, real:%d, pri:%d",
+                               pid, expected_policy, result_policy, param.sched_priority);
+       }
+       return 0;
+}
```

# user thread set thread attr
```
		ivr_cpu_set_affinity(IVR_CPU4, IVR_PRIORITY_WARP, IVR_SCHED_RT_FIFO);
		maliRenderTid = get_thread_id("mali-render");
		if (maliRenderTid > 0) {
			ivr_cpu_set_affinity_bytid(maliRenderTid, IVR_CPU5, IVR_PRIORITY_MALI, IVR_SCHED_RT_FIFO);
		}
		maliEventTid = get_thread_id("mali-event-hnd");
		if (maliEventTid > 0) {
			ivr_cpu_set_affinity_bytid(maliEventTid, IVR_CPU2, IVR_PRIORITY_MALI, IVR_SCHED_RT_FIFO);
		}
```