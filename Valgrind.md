# Introduction #

Add your content here.


# Cross Complie #
```
./configure --prefix=`pwd`/build --host=arm-hisiv200-linux
```
出现Unsupported host architecture错误，
参考http://bbs.chinaunix.net/forum.php?mod=viewthread&action=printable&tid=3557792 上方法可以解决。
```
交叉编译总会遇到这样那样的问题是需要手动去调整和修改的
像楼主这个问题只需要调整configure脚本就可以了
具体应该在检查host_os变量里加入匹配arm条件就行了，如原有的armv7*)改成armv7*|arm)
```

# Run #
在单板上运行出现如下错误：
```
# ./valgrind
valgrind: failed to start tool 'memcheck' for platform 'arm-linux': No such file or directory
```
解决办法：
  1. 先安装[strace](strace.md),找出memcheck-arm-linux的查找路径
  1. memcheck-arm-linux的查找路径安装所需的库