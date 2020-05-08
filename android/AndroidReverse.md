# System.loadLibrary原理
* 最终调用dlopen打开so
* 通过dlsym解析出JNI_OnLoad()，并调用

# Android Arm Inline Hook
[hook](hook.md)