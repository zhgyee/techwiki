# interfaces
## user mode interface
```
/dev/name
```
## KAPI
* register a named list element in the parameter list, along with an initial element target value
  ** int pm_qos_add_requirement(int qos, char* name, s23 value)
* update the value of the named element
  ** int pm_qos_update_requirement(int qos, char* name, s32 value)
* clean up/remove named element
  ** void pm_qos_remove_requirement(int qos, char*name)
* poll the aggregated target value
  ** int pm_qos_requirement(int qos)
* register a notifier into the parameter notification chain
  ** int pm_qos_add_notifier(int qos, struct notifier_block *notifier)
  ** int pm_qos_remove_notifier()

# 8890 GPU QOS
## user sapce interface
```
static struct QosDir gPowerQosDir[PM_QOS_NUM] = {
    { PM_QOS_DEVICE_THROUGHPUT, "/dev/device_throughput_max" },
    { PM_QOS_BUS_THROUGHPUT, "/dev/bus_throughput_max" },
    { PM_QOS_CLUSTER0_FREQ, "/dev/cluster0_freq_max" },
    { PM_QOS_CLUSTER1_FREQ, "/dev/cluster1_freq_max" },
    { PM_QOS_CLUSTER0_NUM, "/dev/cluster0_num_max" },
    { PM_QOS_CLUSTER1_NUM, "/dev/cluster1_num_max" },

    { PM_QOS_DISPLAY_THROUGHPUT, "/dev/display_throughput_max" },
    { PM_QOS_GPU_FREQ_MIN, "/dev/gpu_freq_min" },
    { PM_QOS_GPU_FREQ_MAX, "/dev/gpu_freq_max" },
    { PM_QOS_CAM_THROUGHPUT, "/dev/cam_throughput_max" },
}

```
## kernel impl
```
#include <linux/pm_qos.h>
#ifdef CONFIG_EXYNOS_GPU_PM_QOS
static int exynos_gpu_min_qos_handler(struct notifier_block *b, unsigned long val, void *v)
{
        struct exynos_context *platform = (struct exynos_context *)pkbdev->platform_context;

       if (val)
       {
               gpu_dvfs_clock_lock(GPU_DVFS_MIN_LOCK, PMQOS_LOCK, val);
       }
       else
       {
               gpu_dvfs_clock_lock(GPU_DVFS_MIN_UNLOCK, PMQOS_LOCK, 0);
       }
       return NOTIFY_OK;
}

static struct notifier_block exynos_gpu_min_qos_notifier = {
       .notifier_call = exynos_gpu_min_qos_handler,
};

static int exynos_gpu_max_qos_handler(struct notifier_block *b, unsigned long val, void *v)
{
        struct exynos_context *platform = (struct exynos_context *)pkbdev->platform_context;

       if (val == platform->gpu_max_clock)
               gpu_dvfs_clock_lock(GPU_DVFS_MAX_UNLOCK, SYSFS_LOCK, 0);
       else
               gpu_dvfs_clock_lock(GPU_DVFS_MAX_LOCK, SYSFS_LOCK, val);

       return NOTIFY_OK;
}

static struct notifier_block exynos_gpu_max_qos_notifier = {
       .notifier_call = exynos_gpu_max_qos_handler,
};
#endif
int gpu_notifier_init(struct kbase_device *kbdev)
{
...
	
#ifdef CONFIG_EXYNOS_GPU_PM_QOS
	pm_qos_add_notifier(PM_QOS_GPU_FREQ_MIN, &exynos_gpu_min_qos_notifier);
	pm_qos_add_notifier(PM_QOS_GPU_FREQ_MAX, &exynos_gpu_max_qos_notifier);
#endif

	return 0;
}
void gpu_notifier_term(void)
{
#ifdef CONFIG_EXYNOS_GPU_PM_QOS
	pm_qos_remove_notifier(PM_QOS_GPU_FREQ_MIN, &exynos_gpu_min_qos_notifier);
	pm_qos_remove_notifier(PM_QOS_GPU_FREQ_MAX, &exynos_gpu_max_qos_notifier);
#endif
	return;
}

```