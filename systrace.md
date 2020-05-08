# general used script
```
python systrace.py -b 20480 --time=5 -o mytrace.html gfx input view wm am sm hal res dalvik bionic power sched irq freq idle disk mmc load sync workq memreclaim regulators -a $1
```
# enable gltrace
```
/**
 * There are three different tracing methods:
 * 1. libs/EGL/trace.cpp: Traces all functions to systrace.
 *    To enable:
 *      - set system property "debug.egl.trace" to "systrace" to trace all apps.
 * 2. libs/EGL/trace.cpp: Logs a stack trace for GL errors after each function call.
 *    To enable:
 *      - set system property "debug.egl.trace" to "error" to trace all apps.
 * 3. libs/EGL/trace.cpp: Traces all functions to logcat.
 *    To enable:
 *      - set system property "debug.egl.trace" to 1 to trace all apps.
 *      - or call setGLTraceLevel(1) from an app to enable tracing for that app.
 * 4. libs/GLES_trace: Traces all functions via protobuf to host.
 *    To enable:
 *        - set system property "debug.egl.debug_proc" to the application name.
 *      - or call setGLDebugLevel(1) from the app.
 */
```
# 解决chrome不能显示thread info

打开trace.html，删除所有window.history的函数
# systrace嵌套问题
python systrace.py -b 增加kernel trace buffer size

# ftrace
```
/sys/kernel/debug
```
# Wall time & cpu time
cpu time是真正运行的时间，cpu从runnable状态转到running时，才累计cpu time，而wall time是整体的耗时。

# tracing kernel function

```
-k <KFUNCS>
--ktrace=<KFUNCS>	Trace the activity of specific kernel functions, specified in a comma-separated list.

```
# atrace
```
adb shell atrace -b 10000 -c am shedgfx view --async_start > C:\Users\user1\Desktop\log.txt 

adb shell atrace -b 10000 -c am shedgfx view --async_dump  > C:\Users\user1\Desktop\log.txt 

adb shell atrace -b 10000 -c am shedgfx view --async_stop > C:\Users\user1\Desktop\log.txt 
```
# systrace with atrace
 - modify atrace source, add new trace categories
```
static const TracingCategory k_categories[] = {
    { "display",    "Kernel display", 0, {
        { REQ,      "/sys/kernel/debug/tracing/events/display/enable" },
        { REQ,      "/sys/kernel/debug/tracing/events/display/window_update/enable" },
        { REQ,      "/sys/kernel/debug/tracing/events/display/update_windows/enable" },
        { REQ,      "/sys/kernel/debug/tracing/events/display/sync_windows/enable" },
    } },
}
```
 - compile & push atrace
 - using systrace with new categ
```
python systrace.py --time=10 -o mynewtrace.html gfx display view workq
```
 - open mynewtrace.html with subl editor
 analysing tracing result
  	- workq seq:
```
Binder_2-215   (  149) [002] d..2  8398.837669: workqueue_queue_work: work struct=ee5bc404 function=tegra_dc_ext_flip_worker workqueue=eb7524c0 req_cpu=4 cpu=4294967295
Binder_2-215   (  149) [002] d..2  8398.837676: workqueue_activate_work: work struct ee5bc404
kworker/u8:0-6     (    6) [001] ...1  8398.837712: workqueue_execute_start: work struct ee5bc404: function tegra_dc_ext_flip_worker
kworker/u8:0-6     (    6) [001] ...1  8398.841390: workqueue_execute_end: work struct ee5bc404
```
 	- user space function call
 ```
Binder_2-215   (  149) [002] ...1  8398.837201: tracing_mark_write: B|149|hwc_prepare_display
Binder_2-215   (  149) [002] ...1  8398.837304: tracing_mark_write: E
 ```

# trace in NDK

All it takes is writing properly formatted strings to /sys/kernel/debug/tracing/trace_marker, which can be opened without problems. Below is some very minimal code based on the cutils header and C file. I preferred to re-implement it instead of pulling in any dependencies, so if you care a lot about correctness check the rigorous implementation there, and/or add your own extra checks and error-handling.

```
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define ATRACE_MESSAGE_LEN 256
static int     atrace_marker_fd = -1;

void trace_init()
{
  atrace_marker_fd = open("/sys/kernel/debug/tracing/trace_marker", O_WRONLY);
  if (atrace_marker_fd == -1)   { /* do error handling */ }
}

inline void trace_begin(const char *name)
{
    char buf[ATRACE_MESSAGE_LEN];
    int len = snprintf(buf, ATRACE_MESSAGE_LEN, "B|%d|%s", getpid(), name);
    write(atrace_marker_fd, buf, len);
}

inline void trace_end()
{
    char c = 'E';
    write(atrace_marker_fd, &c, 1);
}

inline void trace_counter(const char *name, const int value)
{
    char buf[ATRACE_MESSAGE_LEN];
    int len = snprintf(buf, ATRACE_MESSAGE_LEN, "C|%d|%s|%i", getpid(), name, value);
    write(atrace_marker_fd, buf, len);
}

inline void trace_async_begin(const char *name, const int32_t cookie)
{
    char buf[ATRACE_MESSAGE_LEN];
    int len = snprintf(buf, ATRACE_MESSAGE_LEN, "S|%d|%s|%i", getpid(), name, cookie);
    write(atrace_marker_fd, buf, len);
}

inline void trace_async_end(const char *name, const int32_t cookie)
{
    char buf[ATRACE_MESSAGE_LEN];
    int len = snprintf(buf, ATRACE_MESSAGE_LEN, "F|%d|%s|%i", getpid(), name, cookie);
    write(atrace_marker_fd, buf, len);
}

```
