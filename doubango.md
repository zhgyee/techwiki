#compile
1. Installing Android NDK r10e
Download Android NDK r10e into /tmp. This is needed only for the first time.

cd /tmp
wget http://dl.google.com/android/ndk/android-ndk-r10e-linux-x86_64.bin
./android-ndk-r10e-linux-x86_64.bin

2. Set $NDK
You must set the $NDK variable:
export NDK=/tmp/android-ndk-r10e

3. Checking out Doubango code
Chekout Doubango v2.0 into /tmp:
cd /tmp
svn checkout https://doubango.googlecode.com/svn/branches/2.0/doubango doubango

4. Generate the configure file
The build system uses GNU AutoTools. The first step is to generate the configure file:
cd /tmp/doubango
./autogen.sh

5. Building the code
Each script will build the code for all supported architectures.
./android_build.sh gpl

The binaries will be generated into /tmp/doubango/android-projects/output/gpl/imsdroid/libs/armeabi-v7a/.
## 编译错误修改
在执行autogen.sh之前，修改下面两个文件
```
configure.ac
plugins/audio_opensles/Makefile.am
```
将上面两个文件中NDK相关的配置修改为跟当前NDK匹配如：
```
-$NDK/build/tools/make-standalone-toolchain.sh --platform=android-3 --install-dir=$ANDROID_TOOLCHAIN
+$NDK/build/tools/make-standalone-toolchain.sh --platform=android-21 --install-dir=$ANDROID_TOOLCHAIN --toolchain=arm-linux-androideabi-4.8
-export SYSROOT=$NDK/platforms/android-3/arch-arm
+export SYSROOT=$NDK/platforms/android-21/arch-arm
-libplugin_audio_opensles_la_CPPFLAGS += -DANDROID=1 -fno-rtti -fno-exceptions -I${NDK}/platforms/android-9/arch-${TARGET_ARCH}/usr/include
-libplugin_audio_opensles_la_LDFLAGS +=  -Wl,-shared,-Bsymbolic,--no-undefined,--whole-archive -L${NDK}/platforms/android-9/arch-${TARGET_ARCH}/usr/lib -lOpenSLES -lm 
+libplugin_audio_opensles_la_CPPFLAGS += -DANDROID=1 -fno-rtti -fno-exceptions -I${NDK}/platforms/android-21/arch-${TARGET_ARCH}/usr/include
+libplugin_audio_opensles_la_LDFLAGS +=  -Wl,-shared,-Bsymbolic,--no-undefined,--whole-archive -L${NDK}/platforms/android-21/arch-${TARGET_ARCH}/usr/lib -lOpenSLES -lm
```
## doubango与webrtc链接
目前采用方法：将libtinyWRAP.so链接到libwebrtc.so上，然后将imsdroid中ngn stack中的librinyWRAP.so删除掉，使用push到/system/lib/下面的库，这样方便调试。
webrtc如何编译成动态库请参考[gyp](gyp.md)

#参考资源
http://www.cnblogs.com/fuland/p/3654839.html
http://www.shuyangyang.com.cn/jishuliangongfang/qitajishu/2013-07-26/96.html
