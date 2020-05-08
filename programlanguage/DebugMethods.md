# Introduction #

Add your content here.


# 打印内核当前调用函数 #

linux kernel中，若函数指针嵌套太深，例如，vma->vm\_file->f\_op->mmap，你知道mmap的指向哪个真正的函数？ok，查代码！运行过程中能否打印呢？
可以的，使用print\_symbol函数，其要求内核配置内核符号表一定选中。用法如下：
> print\_symbol(KERN\_ALERT "vma->vm\_file->f\_op->mmap: %s\n", (unsigned long)vma->vm\_file->f\_op->mmap);
更进一步，可打印当前函数的调用者：
> unsigned long pc = (unsigned long)builtin\_return\_address(0);
> print\_symbol(" caller: %s\n", (unsigned long)pc);