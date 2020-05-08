# Introduction #

Add your content here.


# Makefile #

LOCAL\_LDFLAGS := -L/$(LOCAL\_PATH)/lib/arm-eabi-android/ -lsomelib
## reference
https://www.ibm.com/developerworks/cn/opensource/os-cn-android-build/
# showcommands #

mm showcommands
mm module_name 编译本模块以及依赖模块
make showcommands


[logcat](logcat.md)

[CallStack](CallStack.md)# Introduction #

# component #
[stagefright](stagefright.md)

[nuplayer](nuplayer.md)

# build #
Android develop上关于Android.mk的常量都做了详细介绍：

http://www.kandroid.org/online-pdk/guide/build_cookbook.html

#add so for release 
```
device/samsung/avl7420/full_avl7420.mk

```

#system setting
```
frameworks/base/packages/SettingsProvider/res/values/defaults.xml
```
