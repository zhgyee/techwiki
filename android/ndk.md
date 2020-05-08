# setup ndk in eclipse
## ndk path setting
Preference->Android->ndk->ndk location

## set ndk platform etc.
# API select using abiFilters
```
    defaultConfig {
        minSdkVersion 24
        targetSdkVersion 26
        versionCode 1
        versionName "1.0"

        testInstrumentationRunner "android.support.test.runner.AndroidJUnitRunner"

        ndk {
            abiFilters 'armeabi-v7a', 'arm64-v8a'
        }
    }
```
# application.mk
```
APP_PLATFORM := android-19

APP_ABI := armeabi-v7a

APP_STL := gnustl_static

APP_LDFLAGS := -Wl,--build-id

NDK_TOOLCHAIN_VERSION := 4.8
APP_OPTIM := release

#APP_CPPFLAGS	+= -std=c++11

APP_OPTIM := release
```
## eclipse index setting
set ndk include dir into eclipse preprocess path

# android native api
## c/c++ library
## log
```
LOCAL_LDLIBS := -llog
```
## ZLib
```
LOCAL_LDLIBS := -lz
```
## Dynamic linker library
```
LOCAL_LDLIBS := -ldl
```
## OpenGLES/EGL/Vulkan
```
#include <EGL/egl.h>
#include <EGL/eglext.h>
LOCAL_LDLIBS := -lGLESv1_CM 
LOCAL_LDLIBS := -lGLESv2
LOCAL_LDLIBS += lEGL
//OpenGL ES 3.0
<GLES3/gl3.h>
<GLES3/gl3ext.h>
LOCAL_LDLIBS += -lGLESv3
//OpenGL ES 3.1
<GLES3/gl31.h>
<GLES3/gl3ext.h>
LOCAL_LDLIBS += -lGLESv3
//vulkan
<vulkan/vulkan.h>
//GLES 3.2
<GLES3/gl32.h>
<GLES3/gl3ext.h>
LOCAL_LDLIBS ++ -lGLESv3
```
## jnigraphics
```
AndroidBitmap_getInfo[lockPixels|unlockPixels]()
LOCAL_LDLIBS += -ljnigraphics
#include <android/bitmap.h>
```
## Audio
```
#include <SLES/openSLES.h>
#include <SLES/OpenSLES_Platform.h>
#include <SLES/OpenSLES_Android.h>
#include <SLES/OpenSLES_AndroidConfiguration.h>

LOCAL_LDLIBS += -lOpenSLES

<aaudio/AAudio.h>
```
## Android native application APIs
```
#include <android/native_activity.h>
#include <android/looper.h>
#include <android/input.h>
#include <android/keycodes.h>
#include <android/sensor.h>
#include <android/rect.h>
#include <android/window.h>
#include <android/native_window.h>
#include <android/native_window_jni.h>
#include <android/congituration.h>
#include <android/asset_manager.h>
#include <android/storage_manager.h>
#include <android/obb.h>
#include <android/trace.h>
#include <android/choreographer.h>
#include <android/hardware_buffer.h>
#include <android/hardware_buffer_jni.h>
#include <android/sharemem.h>
#include <android/multinetwork.h>
LOCAL_LDLIBS += -landorid
```

## OpenMaxAL
```
<OMXAL/OpenMAXAL.h>
<OMXAL/OpenMAXAL_Platform.h>
<OMXAL/OpenMAXAL_Android.h>
LOCAL_LDLIBS += -lOpenMAXAL
```