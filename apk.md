# start an unkown apk by am
* dump apk info, find the main activity
aapt dump badging apps/VRSetting_201603021535.apk
* start the activity by am
adb shell am start -an com.idealsee.settings/.UnityPlayerActivity

# apktool反编译
[see](https://ibotpeaches.github.io/Apktool/)
```
apktool.bat d test.apk
```