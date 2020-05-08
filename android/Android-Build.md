# Luncher menifest
```
<action android:name="android.intent.action.MAIN" />
<category android:name="android.intent.category.HOME" />
<category android:name="android.intent.category.DEFAULT" />
```
# 导出符号控制
```
VER_1 {
    global:
        vis_f1;
        vis_f2;
    local:
        *;
};
//导出c++符号
{
  global:
    extern "C++" {
        sxr::xrCore;
    };
  local: *;
};
LOCAL_LDFLAGS     += -Wl,--version-script,$(LOCAL_PATH)/xrcore.exports
```

# 提示内存不够时VM配置
```
export JACK_SERVER_VM_ARGUMENTS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx4g"
```
# Adding a new package
```
build/target/product/core.mk
PRODUCT_PACKAGES += xxx
```
# Adding a new program to build
```
ANDROID/build/core/main.mk

```
[Android_Build_System](http://elinux.org/Android_Build_System)

# Adding a new lib to build
```
devices/samsung/xxx/xxx.mk
```

# import-module
```
# Define the directories for $(import-module, ...) to look in
ROOT_DIR := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))
NDK_MODULE_PATH := $(ROOT_DIR)
# 引用vrapi模块，路径根据NDK_MODULE_PATH来查找
$(call import-module,VrApi/OvrApi/Projects/AndroidPrebuilt/jni)
```

# 打印调试
```
LOCAL_PATH := $(call my-dir)
$(warning $(LOCAL_PATH))
$(info $(LOCAL_PATH))
$(error "finishing copy")
```

# 执行shell 命令
```
$(shell cp -r $(BASE_PATH)/libs/Android $(BASE_PATH)/OvrApi/Libs/)
```

# ndk中库的依赖和连接
application.mk
```
APP_OPTIM := debug
APP_ABI := armeabi-v7a
APP_STL := stlport_static 
APP_CPPFLAGS := -frtti -fexceptions
APP_PLATFORM := android-19
APP_BUILD_SCRIPT := makefiles/Android.mk
```
top level Android.mk
```
TOP_LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

include $(TOP_LOCAL_PATH)/../src/submodules/Android.mk
include $(TOP_LOCAL_PATH)/../src/main/Android.mk
```

main app
```
LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)
LOCAL_SRC_FILES:= compute.cpp
LOCAL_MODULE:= compute
LOCAL_STATIC_LIBRARIES:= add mul
include $(BUILD_EXECUTABLE)
```
add model
```
LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)
LOCAL_SRC_FILES:= ./add.cpp
LOCAL_MODULE:= add
include $(BUILD_STATIC_LIBRARY)
```
