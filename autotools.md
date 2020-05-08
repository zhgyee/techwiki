# Introduction #

Add your content here.

# reference #
http://www.freesoftwaremagazine.com/books/autotools_a_guide_to_autoconf_automake_libtool

专业教程，非常详细的介绍http://www.lrde.epita.fr/~adl/autotools.html
# Details #
##  整体流程 ## 
```
autoreconf -i
./configure --host=arm-hisiv200-linux -prefix=`pwd`/build
make && make install 
```
##  交叉编译 ## 
```
./configure --host=arm-hisiv200-linux
```
##  辅助文件如何发布 ## 
[EXTRA\_DIST](EXTRA_DIST.md)
```
EXTRA_DIST = libflaim.changes libxflaim.changes Android.mk
```
used the EXTRA\_DIST variable here to ensure that additional top-level files get distributed.
##  静态库文件(xx.a)链接问题 ## 
[LDADD](LDADD.md)

如果在ldflag中指定gtest.a则在ld的时候提示找不到符号，看原因是将gtest.a放在-o之前了，解决方法如下：
jupiter\_LDADD = ../common/libjupcommon.a
这样可以使.a文件放在所有的.o之后，问题解决。

详细请参考：http://www.freesoftwaremagazine.com/articles/automatically_writing_makefiles_with_autotools

#LIBADD
LIBADD是新版本中替代LDADD的
If you had other non-libtool libraries, you would also add these with -L and -l options:

libfoo_la_LIBADD = libbar.la -L/opt/local/lib -lpng

##  commands ## 
reconfig整个工程
```
autoreconf -i
```
make distclean
aclocal
autoconf
./configure
##  dist ## 
```
make dist
```
##  configure.ac ## 
```
AC_CONFIG_FILES(Makefile
                libHidrm/Makefile
                include/Makefile
                plugins/Makefile
                plugins/passthru/Makefile
                plugins/playready/Makefile
                TestProgram/Makefile)
```
##  makefile.am ## 
dynamic lib format:
```
lib_LTLIBRARIES = libhipdy.la

## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## #
# Build information for each library

# Sources for libHidrm
libhipdy_la_SOURCES = xx.c xx.h

# Linker options libTestProgram
libhipdy_la_LDFLAGS = $(top_srcdir)/libHidrm/libHidrm.la

# Compiler options. Here we are adding the include directory
# to be searched for headers included in the source code.
libhipdy_la_CPPFLAGS = -I$(top_srcdir)/include \
	-I./include/
```

execute file
```
noinst_PROGRAMS=hidrm
hidrm_SOURCES= HiDRMTest.cpp
hidrm_LDFLAGS = $(top_srcdir)/libHidrm/libHidrm.la -lpthread
hidrm_CPPFLAGS = -I$(top_srcdir)/include 
```

#dir

```
SUBDIRS=libHidrm include plugins plugins/passthru plugins/playready TestProgram
```
如果库A依赖于B，则B目录要放在A目录之前

# package config
```
prefix=/usr/local
exec_prefix=${prefix}
includedir=${prefix}/include
libdir=${exec_prefix}/lib

Name: foo
Description: The foo library
Version: 1.0.0
Cflags: -I${includedir}/foo
Libs: -L${libdir} -lfoo
```
* Name: A human-readable name for the library or package. This does not affect usage of the pkg-config tool, which uses the name of the .pc file.
* Description: A brief description of the package.
* URL: An URL where people can get more information about and download the package.
* Version: A string specifically defining the version of the package.
* Requires: A list of packages required by this package. The versions of these packages may be specified using the comparison operators =, <, >, <= or >=.
* Requires.private: A list of private packages required by this package but not exposed to applications. The version specific rules from the Requires field also apply here.
* Conflicts: An optional field describing packages that this one conflicts with. The version specific rules from the Requires field also apply here. This field also takes multiple instances of the same package. E.g., Conflicts: bar < 1.2.3, bar >= 1.3.0.
* Cflags: The compiler flags specific to this package and any required libraries that don't support pkg-config. If the required libraries support pkg-config, they should be added to Requires or Requires.private.
* Libs: The link flags specific to this package and any required libraries that don't support pkg-config. The same rule as Cflags applies here.
* Libs.private: The link flags for private libraries required by this package but not exposed to applications. The same rule as Cflags applies here.

#Turn thin archive into normal one
chrome等其它开源库常用此方式管理静态库
ar -t can be used to enumerate the object files in an archive, so after that it's just a matter of providing that list to ar as you usually would when creating an archive.
```
for lib in `find -name '*.a'`;
    do ar -t $lib | xargs ar rvs $lib.new && mv -v $lib.new $lib;
done
```