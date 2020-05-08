# ptrace远程注入
ptrace可以读写远程进程的寄存器或内存，以及调用远程函数。如下面例子，通过ptrace让远程进程执行dlopen打开动态库。
```
    //远程申请的Buffer首地址
    lpMmapBase = Regs.ARM_r0;

    pfndlopen = GetRemoteFunctionAddr(nPid, LINKER_PATH, (void *)dlopen);
    pfndlsym = GetRemoteFunctionAddr(nPid, LINKER_PATH, (void *)dlsym);
    pfndlclose = GetRemoteFunctionAddr(nPid, LINKER_PATH, (void *)dlclose);
    pfnsleep = GetRemoteFunctionAddr(nPid, LIBC_PATH, (void *)sleep);


    DEBUG_PRINT("[+] Get imports: dlopen: %p, dlsym: %p, dlclose: %p\r\n",
                pfndlopen, pfndlsym, pfndlclose);

    printf("lpLibraryPath Length: %d\r\n", strlen(lpLibraryPath) + 1);

    //远程申请的Buffer首地址写入需要注入的so路径
    if (PtraceWriteProcessMemory(nPid, lpMmapBase, lpLibraryPath, strlen(lpLibraryPath) + 1) == -1)
    {
        DEBUG_PRINT("[-]InjectRemoteProcess::PtraceWriteProcessMemory Error\r\n");
        nRet = -1;
        goto SAFE_END;
    }

    //传递参数, 准备调用dlopen  void * dlopen(const char * pathname, int mode);
    ParamArg[0] = lpMmapBase;
    ParamArg[1] = RTLD_NOW| RTLD_GLOBAL;

    if (CallRemoteFunction(nPid, "dlopen", pfndlopen, ParamArg, 2, &Regs) == -1)
    {
        nRet = -1;
        goto SAFE_END;
    }
```
Androd so注入和函数Hook（基于got表）的步骤：
- ptrace附加目标pid进程；
- 在目标pid进程中，查找内存空间（用于存放被注入的so文件的路径和so中被调用的函数的名称或者shellcode）；
- 调用目标pid进程中的dlopen、dlsym等函数，用于加载so文件实现Android so的注入和函数的Hook；
- 释放附加的目标pid进程和卸载注入的so文件。

# jdwp java远程注入

# inline hook
Inline Hook即内部跳转Hook，通过替换函数开始处的指令为跳转指令，使得原函数跳转到自己的函数，通常还
会保留原函数的调用接口。与GOT表Hook相比，Inline Hook具有更广泛的适用性，几乎可以Hook任何函数，
不过其实现更为复杂，考虑的情况更多，并且无法对一些太短的函数Hook。
# GOT hook
在使用got表hook时，只能完成对外部符号的hook操作，并且针对不同的so库，需要对每一个so库都进行一次
hook操作，但是got表hook的优点在于易实现，只需要修改got表中所存储的偏移地址即可完成对某个外部符号
的hook操作。
# adbi
adbi（The Android Dynamic Binary Instrumentation Toolkit）就是一个通用的框架，使得hook变得异常简单。可以从这里获得其源代码：https://github.com/crmulliner/adbi。

它的基本实现原理是利用ptrace()函数attach到一个进程上，然后在其调用序列中插入一个调用dlopen()函数的步骤，将一个实现预备好的.so文件加载到要hook的进程中，最终由这个加载的.so文件在初始化函数中hook指定的函数。
整个adbi工具集由两个主要模块组成，分别是用于.so文件注入的进程劫持工具（hijack tool）和一个修改函数入口的基础库。

# interceptor
[see interceptor](interceptor.md)