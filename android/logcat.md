# Introduction #

Add your content here.


# Details #

# 显示时间 #
```
logcat -v time
```

# 显示pid/tid/time #
```
logcat -v threadtime
```
# 过滤 #
```
logcat -s tag
```
#Redirect stdout to logcat in Android NDK
adb root
adb shell stop
adb shell setprop log.redirect-stdio true
adb shell start

# NDK log
```
#include <stdarg.h>
#include <android/log.h>
static int tsk_android_log(const void* arg, const char* fmt, ...) {
    va_list args;
    va_start(args, fmt);
    __android_log_vprint(ANDROID_LOG_DEBUG, "doubango", fmt, args);
    va_end(args);
    return 0;
}
```