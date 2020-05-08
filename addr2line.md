# Introduction #

Add your content here.


# Details #

```
arm-linux-androideabi-addr2line -C -f -e obj/local/armeabi/libnativemaprender.so 0003deb4
```

  1. The -C flag is to demangle C++ code
  1. -f 可以显示出函数名称
  1. so 文件要没有strip的，可在obj/SHARED\_LIBRARIES/下找到