# ovr extention

```
egl_GVR_FrontBuffer
```

# egl 1.4 extention
```
final int[] surfaceAttribsSB = {
		//EGL10.EGL_WIDTH, 16,
		//EGL10.EGL_HEIGHT, 16,
		//EGL10.EGL_SURFACE_TYPE,QCOMHelper.EGL_MUTABLE_RENDER_BUFFER_BIT_KHR,
		//EGL_ANDROID_front_buffer_auto_refresh, EGL14.EGL_TRUE,
		EGL14.EGL_RENDER_BUFFER,EGL14.EGL_SINGLE_BUFFER,
		EGL14.EGL_NONE
};
result = EGL14.eglCreateWindowSurface(display, config, nativeWindow, surfaceAttribsSB, 0);
//swap后进入single buffer
EGL14.eglSwapBuffers(EGL14.eglGetCurrentDisplay(),EGL14.eglGetCurrentSurface(EGL14.EGL_DRAW));
```