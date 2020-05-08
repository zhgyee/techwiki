
# LD\_LIBRARY\_PATH 使用 #

[LD\_LIBRARY\_PATH](LD_LIBRARY_PATH.md)

export LD\_LIBRARY\_PATH=`pwd'

# 有未定义符号时出错 #

linux下默认是不会强制检查未定义的符号的，而转移到了LD的时候检查；
而android下，加载机制不一样，需要在编译时执行所有符号的检查。

修改$(NDK)/build/core/default-build-commands.mk文件，其中$(NDK)为NDK所在目录。
将TARGET\_NO\_UNDEFINED\_LDFLAGS := -Wl,--no-undefined注掉

# 未使用变量出错 #
```
-Werror=unused-but-set-variable
```

# build .a .so
```
all: static_lib liba libb test
static_lib:
        gcc -c -fPIC static_lib.c -o static_lib.o
        ar rcs libstatic.a static_lib.o 
liba:
        gcc -c -fPIC share_liba.c -o share_liba.o
        gcc -shared -o liba.so share_liba.o libstatic.a 
libb:
        gcc -c -fPIC share_libb.c -o share_libb.o
        gcc -shared -o libb.so share_libb.o libstatic.a
test:
        gcc test.c -la -lb -L. -o test

```
# 警告控制
```
SET( CMAKE_CXX_FLAGS         "-std=c++11 -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-but-set-variable -Wno-unused-variable -Wno-narrowing -DUNIX_ENVIRONMENT -DHAVE_NAMESPACES -DHAVE_STD " )
```