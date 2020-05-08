##  Kernel configuration
```
  │ CONFIG_GATOR:                                                                                                                                                                    
  │ Gator module for ARM's Streamline Performance Analyzer  
  │ Symbol: GATOR [=m]
  │ Type  : tristate 
  │ Prompt: Gator module for ARM's Streamline Performance Analyzer 
  │   Location:                                                                                                                                                                      
  │     -> Device Drivers 
  │   Defined at drivers/gator/Kconfig:1  
  │   Depends on: PROFILING [=y] && HIGH_RES_TIMERS [=y] && (LOCAL_TIMERS [=y] || !ARM || !SMP [=y]) && PERF_EVENTS [=y] && (HW_PERF_EVENTS [=y] || !ARM && !ARM64 [=y])
  │   Selects: TRACING [=y]   
```
menuconfig options (depending on the kernel version, the location of these configuration settings within menuconfig may differ)
```
- General Setup
  - Kernel Performance Events And Counters
    - [*] Kernel performance events and counters (enables CONFIG_PERF_EVENTS)
  - [*] Profiling Support (enables CONFIG_PROFILING)
- [*] Enable loadable module support (enables CONFIG_MODULES, needed unless the gator driver is built into the kernel)
  - [*] Module unloading (enables MODULE_UNLOAD)
- Kernel Features
  - [*] High Resolution Timer Support (enables CONFIG_HIGH_RES_TIMERS)
  - [*] Use local timer interrupts (only required for SMP and for version before Linux 3.12, enables CONFIG_LOCAL_TIMERS)
  - [*] Enable hardware performance counter support for perf events (enables CONFIG_HW_PERF_EVENTS)
- CPU Power Management
  - CPU Frequency scaling
    - [*] CPU Frequency scaling (enables CONFIG_CPU_FREQ)
- Device Drivers
  - Graphics support
    - ARM GPU Configuration
      - Mali Midgard series support
        - [*] Streamline Debug support (enables CONFIG_MALI_GATOR_SUPPORT needed as part of Mali Midgard support)
- Kernel hacking
  - [*] Compile the kernel with debug info (optional, enables CONFIG_DEBUG_INFO)
  - [*] Tracers
    - [*] Trace process context switches and events (#)
```
##  Building the gator module

To create the gator.ko module,
```
cd /path/to/kernel
make -j
cp -r /path/to/streamline/gator/driver .
cd driver
make -C <kernel_build_dir> M=`pwd` ARCH=arm CROSS_COMPILE=<...> modules

```  
patch for successful compile gator
```
diff --git a/driver/gator_events_mali_midgard_hw.c b/driver/gator_events_mali_midgard_hw.c
index 2805685..1ef4bb7 100644
--- a/driver/gator_events_mali_midgard_hw.c
+++ b/driver/gator_events_mali_midgard_hw.c
@@ -41,7 +41,7 @@
 #endif
 
 #if !defined(CONFIG_MALI_GATOR_SUPPORT)
-#error CONFIG_MALI_GATOR_SUPPORT is required for GPU activity and software counters
+//#error CONFIG_MALI_GATOR_SUPPORT is required for GPU activity and software counters
 #endif
 
 #include "gator_events_mali_common.h"
diff --git a/driver/mali_midgard.mk b/driver/mali_midgard.mk
index 101d0a8..a003ebd 100644
--- a/driver/mali_midgard.mk
+++ b/driver/mali_midgard.mk
@@ -7,7 +7,8 @@ EXTRA_CFLAGS += -DMALI_USE_UMP=1 \
                 -DMALI_CUSTOMER_RELEASE=1 \
                 -DMALI_UNIT_TEST=0 \
                 -DMALI_BACKEND_KERNEL=1 \
-                -DMALI_NO_MALI=0
+                -DMALI_NO_MALI=0 \
+               -DMALI_GCC_WORKAROUND_MIDCOM_4598=0
 
 DDK_DIR ?= .

```
##  Building the gator daemon
```
mv daemon jni
ndk-build
```

## adb setup
```
adb forward tcp:8080 tcp:8080
```
##  Running gator

- Load the kernel onto the target and copy gatord and gator.ko into the target's filesystem.
- Ensure gatord has execute permissions `chmod +x gatord`
- gator.ko must be located in the same directory as gatord on the target or the location specified with the -m option or already insmod'ed.
- With root privileges, run the daemon `sudo ./gatord &`
- If gator.ko is not loaded and is not in the same directory as gatord when using Linux 3.4 or later, gatord can run without gator.ko by using userspace APIs. Not all features are supported by userspace gator. If `/dev/gator/version` does not exist after starting gatord it is running userspace gator.