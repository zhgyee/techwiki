# Does not support 64-bit on android
Unity does not currently support 64-bit native plugins on Android. So you must use a 32-bit version. Notice the values for the "Architecture" option in the Player Settings for the Android target (in the Unity Editor). They are ARMv7 and x86, both 32-bit architectures.

Unity could support 64-bit targets for Android at some point in the future, but I don't know of any current plans to do so.

# export android project
* build setting->build system(gradle) ->export project
* fix import error by update gradle while import in android studio

```
dependencies {
        classpath 'com.android.tools.build:gradle:2.3.2'
    }
```