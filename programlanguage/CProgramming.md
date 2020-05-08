# Introduction #

Add your content here.

# reference #
很全面的宏的用法 http://gcc.gnu.org/onlinedocs/cpp/Macros.html#Macros
# Details #

#pragma message(“消息文本”)

##  关 于...的使用 ## 

...在C宏中称为Variadic Macro，也就是变参宏。比如：
```
#define myprintf(templt,...) fprintf(stderr,templt,__VA_ARGS__)
#define LOGD(fmt, ...) av_log(NULL, AV_LOG_DEBUG, fmt"\n", ##__VA_ARGS__)
```
