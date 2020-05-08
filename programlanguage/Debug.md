# 找出占用时间最多的线程ID #

ps: ps是Linux/Unix系统中一个用于报告当前系统进程运行情况的工具。
很多人都用过ps，但是ps还可以用来查询线程执行情况。
下面是查看一个叫hss.hcf\_0程序运行时的线程情况
> ps -eLfP  可以看到绑定到那个cpu上  psr那行
```
#ps -efL|grep hss.hcf_0
root     16768 16604 16924  0   48 11:00 ?        00:44:00 /opt/ne/0051/proc/FFFFFFFF/prog/hss.hcf_0
root     16768 16604 16925  0   48 11:00 ?        00:00:00 /opt/ne/0051/proc/FFFFFFFF/prog/hss.hcf_0
root     16768 16604 16926  0   48 11:00 ?        00:01:57 /opt/ne/0051/proc/FFFFFFFF/prog/hss.hcf_0
root     16768 16604 16927  0   48 11:00 ?        00:00:53 /opt/ne/0051/proc/FFFFFFFF/prog/hss.hcf_0
root     16768 16604 16928  0   48 11:00 ?        00:00:52 /opt/ne/0051/proc/FFFFFFFF/prog/hss.hcf_0
root     16768 16604 16929  0   48 11:00 ?        00:00:55 /opt/ne/0051/proc/FFFFFFFF/prog/hss.hcf_0
```
上面标蓝的数字是线程号，标粗的时间是该线程占用CPU时间。通过上面对比，我们可以看到标号为16924的线程占用了最多的时间，而且明显比其他线程多几十倍。


# 获取该进程所有线程函数调用栈 #

gdb: gdb是Linux下一款功能异常强大的调试工具。
续上面例子，我们使用gdb连接到hss.hcf\_0进程，16768是hss.hcf\_0的进程号，--command=help.cmd是从help.cmd中读取gdb命令。
gdb --command=help.cmd -p 16768
help.cmd中的内容如下（右边的汉字为命令解释）
thread apply all bt            //打印每一个线程当前的函数调用栈
detach                        //退出进程连接
quit                           //退出gdb

# 配合代码定位死循环具体位置 #
通过调用栈已经可以定位到死循环发生在具体某一个文件某一行，目标范围已经大大缩小，死循环定位已经胜利在望了。
找具体代码时，基本可以分为如下两类：
  1. 调用栈上的代码行正在当前函数的一个循环内.想必不用我再教你怎么看了循环代码了吧：）
  1. 调用栈上的代码行的当前函数没有循环.不要慌张，要相信我们的必杀技一定没有搞错；仔细检查一下是不是当前函数被上层函数循环调用了，一层一层，一定能够找到问题所在。

# 打印内核当前调用函数 #

linux kernel中，若函数指针嵌套太深，例如，vma->vm\_file->f\_op->mmap，你知道mmap的指向哪个真正的函数？ok，查代码！运行过程中能否打印呢？
可以的，使用print\_symbol函数，其要求内核配置内核符号表一定选中。用法如下：
> print\_symbol(KERN\_ALERT "vma->vm\_file->f\_op->mmap: %s\n", (unsigned long)vma->vm\_file->f\_op->mmap);
更进一步，可打印当前函数的调用者：
> unsigned long pc = (unsigned long)builtin\_return\_address(0);
> print\_symbol(" caller: %s\n", (unsigned long)pc);  

# Debug shared library with gdbserver
```
# cat /proc/ 7186/maps
It will output something like:

007b1000-007cc000 r-xp 00000000 08:02 2737838 /lib/ld-2.6.so
007cc000-007cd000 r--p 0001a000 08:02 2737838 /lib/ld-2.6.so
007cd000-007ce000 rw-p 0001b000 08:02 2737838 /lib/ld-2.6.so
08048000-08049000 r-xp 00000000 08:02 1759415 /root/writting/gdbserver/test
08049000-0804a000 rw-p 00000000 08:02 1759415 /root/writting/gdbserver/test
4d940000-4da8e000 r-xp 00000000 08:02 2738392 /lib/libc-2.6.so
4da8e000-4da90000 r--p 0014e000 08:02 2738392 /lib/libc-2.6.so
4da90000-4da91000 rw-p 00150000 08:02 2738392 /lib/libc-2.6.so
4da91000-4da94000 rw-p 4da91000 00:00 0
b7efc000-b7efd000 rw-p b7efc000 00:00 0
b7f11000-b7f12000 r-xp 00000000 08:02 1759414 /root/writting/gdbserver/libfoo.so
b7f12000-b7f13000 rw-p 00000000 08:02 1759414 /root/writting/gdbserver/libfoo.so
b7f13000-b7f14000 rw-p b7f13000 00:00 0
bff04000-bff19000 rw-p bffeb000 00:00 0 [stack]
ffffe000-fffff000 r-xp 00000000 00:00 0 [vdso]
```
This means the code segment of libfoo.so is loaded at 0xb7f11000.

8. With the help of objdump, we can get the offset.
```
# objdump -h libfoo.so grep text
It will output something like:

 .text 00000154 000002f0 000002f0 000002f0 2**4
```
So, the offset is 0x000002f0

9. Add the loaded address and offset, we can get the real address.
ADDR=0xb7f11000+0x000002f0=0xb7f112f0

10. Now, we can load the symbol file into gdb.
(gdb) add-symbol-file libfoo.so 0xb7f112f0
add symbol table from file "libfoo.so" at
.text_addr = 0xb7f112f0
(y or n) y
Reading symbols from /root/writting/gdbserver/libfoo.so...done.

http://linux-mobile-hacker.blogspot.co.uk/2008/02/debug-shared-library-with-gdbserver.html

# 打印内核当前调用函数 #

linux kernel中，若函数指针嵌套太深，例如，vma->vm\_file->f\_op->mmap，你知道mmap的指向哪个真正的函数？ok，查代码！运行过程中能否打印呢？
可以的，使用print\_symbol函数，其要求内核配置内核符号表一定选中。用法如下：
> print\_symbol(KERN\_ALERT "vma->vm\_file->f\_op->mmap: %s\n", (unsigned long)vma->vm\_file->f\_op->mmap);
更进一步，可打印当前函数的调用者：
> unsigned long pc = (unsigned long)builtin\_return\_address(0);
> print\_symbol(" caller: %s\n", (unsigned long)pc);