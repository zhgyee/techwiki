# Introduction #

Add your content here.


# Libtool 库版本号 #
每个系统的库版本机制并不一样，Libtool 通过一种抽象的版本机制，最终在创建库时映射到具体的系统版本机制。
Libtool 的版本号分为 3 个部分 :
  * current: 表示当前库输出的接口的数量 ;
  * revision: 表示当前库输出接口的修改次数 ;
  * age: 表示当前库支持先前的库接口的数量，例如 age为 2，表示它可以和支持当前库接口的执行文件，或者支持前面两个库接口的执行文件进行链接。所以 age应该总是小于或者等于 current。
Libtool 的库版本通过参数 -version-info current:revision:age指定，例如下面的例子 :
```
$ libtool --mode=link gcc -l libcompress.la -version-info 0:1:0 
```
# 避免版本信息 #
有些动态链接库，例如可动态加载模块，不需要版本号，这时可使用 Libtool 的 -avoid-version选项，例如下面的命令 :
```
 $ libtool --mode=link gcc -o libcompress.la compress.lo -rpath /tmp -avoid-version 
```
在Makefile.am中取掉版本号方式如下：
```
# Linker options libTestProgram
libHidrm_la_LDFLAGS = -ldl -avoid-version
```
# Reference #
使用 GNU Libtool 创建库http://www.ibm.com/developerworks/cn/aix/library/1007\_wuxh\_libtool/