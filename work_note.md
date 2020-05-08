# readme
http://10.0.0.90:88/issues/5465#change-15461
adb shell am start -an com.ideaslee.unitytest/com.unity3d.player.UnityPlayerNativeActivity
adb shell am start -an com.idealsee.settings/.UnityPlayerActivity
adb shell am start -an com.google.android.exoplayer.demo/.SampleChooserActivity
adb shell am start -an com.android.gldual/.GLDualActivity
adb shell am start -an com.android.testframerate/.TestFramerateActivity
adb shell am start -an com.android.gl2jni/.GL2JNIActivity
adb shell am start -an com.oculusvr.vrscene/.MainActivity
adb shell am start -an com.idealsee.test1/.UnityPlayerActivity
adb shell am start -an com.example.testdialog/.MainActivity
adb shell am start -an com.unity3d.player.UnityPlayerActivity
adb shell am start -an com.idealsee.test2.UnityPlayerActivity/.MainActivity
adb shell am start -an com.android.settings/.Settings
adb shell am start -an com.idealsee.ivrsdk/com.unity3d.player.UnityPlayerActivity
adb shell am start -an com.edburnette.fps2d/com.edburnette.fps2d.Fps2D
adb shell am start -n com.idsee.ar/.activity.HomeActivity -e "video_path" "/sdcard/test-360.mp4" --ei "video_type" 7
adb shell am start -n com.arm.malideveloper.vrsdk.armvr/.ARMVR
adb shell am start -n com.hoytgm/.hoytgm
adb shell am start -n com.idealsee.physical/.UnityPlayerActivity
adb shell am start -n com.test1/com.unity3d.player.UnityPlayerActivity
am start -a android.intent.action.VIEW -n com.android.browser/.BrowserActivity -d http://output.jsbin.com/device-inertial-sensor-diagnostics
adb shell am broadcast -a test_toast
am start -n com.android.gallery3d/.app.MovieActivity -d /sdcard/Movies/360_韩女热舞.mp4
//VOLUME UP
adb shell input keyevent KEYCODE_VOLUME_UP
com.idealsee.vr.launcher/.
adb shell am start -an com.arm.malideveloper.vrsdk.armvr/.ARMVR
adb shell am start -an com.idsee.ar/.activity.HomeActivity --es video_path "/sdcard/Movies/谍影重重_2D.mp4" --ei video_type "1"
adb push bin/Idealsee-Player-7420.apk /system/app/Idealsee-Player/Idealsee-Player.apk

aapt dump badging apps/VRSetting_201603021535.apk
grep -rn "TPCtr\|debug\|ShutdownThread\|HWComposer::doRefresh" logall.txt
## start apk 
/home/zhgyee/Android/Sdk/tools/emulator -netdelay none -netspeed full -avd Nexus_6P_API_23 -gpu mesa
PowerUI\|Boot animation finished\|launcher\|IVR\|hwcomposer\|Dialog\|DEBUG
# lunch
Build type choices are:
     1. release
     2. debug

Which would you like? [1] 2


Which product would you like? [ardbeg] ardbeg


Variant choices are:
     1. user
     2. userdebug
     3. eng
Which would you like? [eng] 3

# vr lib include config
/home/zhgyee/src/vrlib/VR-SDK/jni/include/LibIVR/Src
/home/zhgyee/src/vrlib/VR-SDK/jni/include/LibIVR/Include
${ANDROID_NDK}/platforms/android-19/arch-arm/usr/include

adb logcat -c && adb logcat -v threadtime | tee video.log
grep -rn "player\|MediaPlayer\|Start proc \|ActivityManager" video.log 

adb push libs/armeabi-v7a/libgl2jni.so /system/lib/
adb push bin/Idealsee-Player.apk /system/app/


javap -s -p bin/classes/com/idsee/ar/activity/HomeActivity.class

## 三星7420项目，对编译依赖已经进行了环境整合，使用方法如下. 

 代码获取路径: 
     #git clone git@10.0.1.56:Android/7420.git
 
 编译方法:
   1) uboot编译：
     #./build.sh avl7420 uboot
   2) kernel编译:
     #./build.sh avl7420 kernel
   3) android编译：
     #./build.sh avl7420 platform

 代码提交:
     #git add FILE
     #git commit -m "INFO"
     #git review


S3CFB_WIN_CONFIG

# 7420
-Compile methods:

   1) uboot

      #./build.sh avl7420 uboot
   
   2) kernel
    
      #./build.sh avl7420 kernel
 
   3) android
  
      #./build.sh avl7420 platform

   4) compile all file

     #./build.sh avl7420 all

-Code commits:

      usage: (dependent tool: sudo apt-get install git-review python-pip)

      #git fetch origin master
      #git add FILE
      #git commit --amend
      #git review

-Document:

  ./docs/bsp

  tests/feed1.ffm
## burnning image
```
sudo /home/zhgyee/workspace/exynos/7420/out/host/linux-x86/bin/fastboot flash kernel kernel/arch/arm64/boot/Image
sudo /home/zhgyee/workspace/exynos/7420/out/host/linux-x86/bin/fastboot flash system out/target/product/avl7420/system.img

```
com.google.android.exoplayer.demo/.SampleChooserActivity