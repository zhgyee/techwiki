#Mali Graphics Debugger

## Android installation
### 32bit
```
cd /home/zhgyee/tools/Mali_Graphics_Debugger_v3.5.0.d6a756e1_Linux_x64/target/android/arm
adb push armeabi-v7a/libGLES_mgd.so /system/lib/egl/libGLES_mgd.so
adb push mgddaemon /system/bin
adb shell
cp /system/lib/egl/egl.cfg /system/lib/egl/egl.cfg.bak
echo "0 0 mgd" > /system/lib/egl/egl.cfg
ln -s /system/lib/egl/libGLES_mgd.so /system/lib/libGLES.so
ln -s /system/lib/egl/libGLES_mgd.so /system/lib/libEGL_mgd.so
ln -s /system/lib/egl/libGLES_mgd.so /system/lib/egl/libGLES.so
//If your system uses a non-monolithic driver

ln -s /system/lib/egl/libGLES_mgd.so /system/lib/egl/libEGL_mgd.so
ln -s /system/lib/egl/libGLES_mgd.so /system/lib/egl/libGLESv1_CM_mgd.so
ln -s /system/lib/egl/libGLES_mgd.so /system/lib/egl/libGLESv2_mgd.so
```
### 64bits
```
adb push arm64-v8a/libGLES_mgd.so /system/lib64/egl/libGLES_mgd.so
adb shell
chmod 777 /system/lib64/egl/libGLES_mgd.so
cp /system/lib64/egl/egl.cfg /system/lib64/egl/egl.cfg.bak
echo "0 0 mgd" > /system/lib64/egl/egl.cfg
ln -s /system/lib64/egl/libGLES_mgd.so /system/lib64/egl/libGLES.so
```
the name of the application that should be traced should have its name written in 
```
echo com.arm.malideveloper.vrsdk.armvr > /system/lib/egl/processlist.cfg
chmod 666 /system/lib/egl/processlist.cfg

chmod 777 /system/bin/mgddaemon
chmod 777 /system/lib/egl/*
```

## debug step
```
adb forward tcp:5002 tcp:5002
adb shell
su
mgddaemon
```

## uninstall
```
rm /system/bin/mgddaemon
rm /system/lib/egl/libGLES_mgd.so
cp /system/lib/egl/egl.cfg.bak /system/lib/egl/egl.cfg
rm /system/lib/egl/libGLES.so
rm /system/lib/egl/libEGL_mgd.so
rm /system/lib/egl/libGLESv1_CM_mgd.so
rm /system/lib/egl/libGLESv2_mgd.so

```
可以实现的功能：
*单步调试运行
*capture framebuffer
*capture FBO
*查看纹理以及FBO纹理
