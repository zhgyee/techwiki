# pm 关闭应用
```
adb shell  pm disable com.android.systemui

```
# 刷新媒体库
```
adb shell am broadcast -a android.intent.action.MEDIA_MOUNTED -d file:///sdcard
```
# dumpsys
```
adb shell dumpsys package
adb shell dumpsys meminfo [pname/pid]
```
# turn off bluetooth in adb shell super user mode (su)
adb shell service call bluetooth_manager 8

# turn on bluetooth
service call bluetooth_manager 6

# build android project with cmdline
```
$ $ANDROID_SDK/tools/android update project --name ARMVR --path . --target android-19
$ ndk-build
$ ant -q debug
$ adb install -r bin/ARMVR-debug.apk
```
对第三方库的引用，路径是相对的，否则可能会出现含有如下文字的异常:  
    resolve to a path with no project.properties file for project  

# adb input


```
adb shell input swipe 500 500 0 0
adb shell input touchpad  tap 0 0

# input                                                          
Usage: input [<source>] <command> [<arg>...]  
  
The sources are:   
      trackball  
      joystick  
      touchnavigation  
      mouse  
      keyboard  
      gamepad  
      touchpad  
      dpad  
      stylus  
      touchscreen  
  
The commands and default sources are:  
      text <string> (Default: touchscreen)  
      keyevent [--longpress] <key code number or name> ... (Default: keyboard)  
      tap <x> <y> (Default: touchscreen)  
      swipe <x1> <y1> <x2> <y2> [duration(ms)] (Default: touchscreen)  
      press (Default: trackball)  
      roll <dx> <dy> (Default: trackball)  
```

# start activity
```
adb shell am start -an com.idealsee.settings/.UnityPlayerActivity
adb shell am start -an com.idsee.ar/.activity.HomeActivity --es video_path "/sdcard/Movies/谍影重重_2D.mp4" --ei video_type "1"
aapt dump badging apps/VRSetting_201603021535.apk
adb shell am start -an com.android.testframerate/.TestFramerateActivity
adb shell am start -an com.android.gldual/.GLDualActivity
```
使用dumpsys获取包名和activity名
```
adb shell dumpsys package | grep "\[com."

adb shell dumpsys package com.skyworth.cylinder
```

# 屏幕旋转
```
adb shell settings put system accelerometer_rotation 0  #disable auto-rotate
adb shell settings put system user_rotation 3  #270° clockwise
accelerometer_rotation: auto-rotation, 0 disable, 1 enable
user_rotation: actual rotation, clockwise, 0 0°, 1 90°, 2 180°, 3 270°
```