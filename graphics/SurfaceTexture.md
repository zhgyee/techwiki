#using SurfaceTexture in JNI
android_graphics_SurfaceTexture.h
Get native SurfaceTexture object from the following api
```
/* Gets the underlying GLConsumer from a SurfaceTexture Java object. */
extern sp<GLConsumer> SurfaceTexture_getSurfaceTexture(JNIEnv* env, jobject thiz);
```
