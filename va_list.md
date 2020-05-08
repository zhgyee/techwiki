# Introduction #

Add your content here.


# 使用va\_list打印输出 #
```
void my_printf(const char* fmt, ...)
#include <stdarg.h>
va_list args;
va_start(args, fmt);
vsnprintf(buf, size, fmt, args)
```