# IDA pro
通过IDA可以逆向native库

# Intercepting Android native library calls
Is it possible to use LD_PRELOAD’s on Android? Yes it is, we can preload shared objects on Android just like we can on other Linux systems. (Though you may not want to attempt this on Android <= 4.0). The apitrace project is a nice example of a project that uses a very similar technique to trace OpenGL, Direct3D, and other graphics APIs.

We then push the shared object to the Android device and preload it into the Dalvik VM by setting the wrap property for the application. You might need root for some of these commands (or remount with read-write permissions):
```

$ adb push libsslover.so /data/libsslover.so
$ setprop wrap.com.xyz.yourapp LD_PRELOAD=/data/libsslover.so
```

[apitrace](https://github.com/apitrace/apitrace)

[frida](https://www.frida.re/docs/examples/android/)

https://www.codeproject.com/Articles/70302/Redirecting-functions-in-shared-ELF-libraries

https://blog.netspi.com/function-hooking-part-i-hooking-shared-library-function-calls-in-linux/

http://www.linuxjournal.com/article/7795