#apitrace
## use in android
```
export PROCNAME=com.idsee.ar
adb push ./build/wrappers/egltrace.so /data/
adb push $ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/4.8/libs/armeabi-v7a/thumb/libgnustl_shared.so /data/
adb shell setprop wrap.$PROCNAME LD_PRELOAD="/data/libgnustl_shared.so:/data/egltrace.so"
adb shell setprop debug.apitrace.procname $PROCNAME
adb shell am start -an com.idsee.ar/.activity.HomeActivity 
adb pull /data/data/$PROCNAME/$PROCNAME.trace

```

#gltrace
## using in eclipse
## using in monitor
