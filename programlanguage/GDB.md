
# GDB调试core-dump文件

```
arm-eabi-gdb ～/Downloads/BUG/455750/symbols/system/bin/app_processb32
set solib-search-path ~/Downloads/BUG/455750/symbols/system/lib
core-file ~/Downloads/BUG/455750/core-Thread-420-3436
```

如果带符号表的so与corefile都正确且匹配，则会出现crash发生时的情景。

# GDB常用命令

```
f n #切换到frame n
disas /m #源码和汇编交错显示
p name #打印变量name
x/1x addr #检查addr处内存
info frame #显示当前frame信息
info threads #显示当前threads运行状态
info registers #显示当前registers
info proc mapping #显示当前进程map地址
list func line #列出代码
up n #frame向上移n个
down n #frame向下移n个
thread apply all bt            //打印每一个线程当前的函数调用栈
thread id //switch to thread, id is first col
```

#GDBClient调试远程程序
##  5.0

``` 
gdbclient
file out/xxx/symblo/system/lib/libxxx.so
b file:line
b function
b *0xaddr
c
```
##  4.4 before

4.4也可以用gdbclient,不过参数不一样，如下：
`gdbclient app_process :5039 com.android.browser `
