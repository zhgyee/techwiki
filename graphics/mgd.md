#Mali Graphics Debugger

## Android installation
### daemon
```
 cd 'F:\Program Files\Arm\Mali Developer Tools\Mali Graphics Debugger v5.1.0\target\android\arm'
adb push mgddaemon /system/bin/
adb shell chmod 777 /system/bin/mgddaemon
```
### 32bit
```
adb push rooted/armeabi-v7a/libGLES_mgd.so /system/lib/egl/
adb shell chmod 777 /system/lib/egl/libGLES_mgd.so
adb shell ln -s /system/lib/egl/libGLES_mgd.so /system/lib/egl/libGLES.so
adb shell ln -s /system/lib/egl/libGLES_mgd.so /system/lib/egl/libGLES
```
### 64bits
```
adb push rooted/arm64-v8a/libGLES_mgd.so /system/lib64/egl/
adb shell chmod 777 /system/lib64/egl/libGLES_mgd.so
adb shell ln -s /system/lib64/egl/libGLES_mgd.so /system/lib64/egl/libGLES.so
adb shell ln -s /system/lib64/egl/libGLES_mgd.so /system/lib64/egl/libGLES
```
the name of the application that should be traced should have its name written in 
```
adb shell 
echo com.ssnwt.vros > /system/lib/egl/processlist.cfg
chmod 666 /system/lib/egl/processlist.cfg

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
