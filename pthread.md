# Introduction #

Add your content here.


# 设置线程名称 #
```
#include <sys/prctl.h>
prctl(PR_SET_NAME, "rtp thread");
```