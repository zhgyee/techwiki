# EGL_ANDROID_presentation_time
    Often when rendering a sequence of images, there is some time at which each
    image is intended to be presented to the viewer.  This extension allows
    this desired presentation time to be specified for each frame rendered to
    an EGLSurface, allowing the native window system to use it.
```
EGLBoolean eglPresentationTimeANDROID(EGLDisplay dpy, EGLSurface surface,
        EGLnsecsANDROID time)
{
    clearError();

    const egl_display_ptr dp = validate_display(dpy);
    if (!dp) {
        return EGL_FALSE;
    }

    SurfaceRef _s(dp.get(), surface);
    if (!_s.get()) {
        setError(EGL_BAD_SURFACE, EGL_FALSE);
        return EGL_FALSE;
    }

    egl_surface_t const * const s = get_surface(surface);
    native_window_set_buffers_timestamp(s->win.get(), time);

    return EGL_TRUE;
}

```
    
# eglGetProcAddress
return a GL or an EGL extension function
```
typedef void * (*PFN_GVR_FrontBuffer)(EGLSurface surface);
PFN_GVR_FrontBuffer egl_GVR_FrontBuffer = NULL;

// look for the extension
egl_GVR_FrontBuffer = (PFN_GVR_FrontBuffer) eglGetProcAddress("egl_GVR_FrontBuffer");
if (egl_GVR_FrontBuffer == NULL) {
        LOG("Not found: egl_GVR_FrontBuffer");
        gvrFrontbuffer = false;
} else {
        LOG("Found: egl_GVR_FrontBuffer");
        void * ret = egl_GVR_FrontBuffer(surface_);
        if (ret) {
                LOG("egl_GVR_FrontBuffer succeeded");
                gvrFrontbuffer = true;
        } else {
                WARN("egl_GVR_FrontBuffer failed");
                gvrFrontbuffer = false;
        }
}

```
# egl sync
```

    EGLSyncKHR eglCreateSyncKHR(
                        EGLDisplay dpy,
                        EGLenum type,
                        const EGLint *attrib_list);

    EGLBoolean eglDestroySyncKHR(
                        EGLDisplay dpy,
                        EGLSyncKHR sync);

    EGLint eglClientWaitSyncKHR(
                        EGLDisplay dpy,
                        EGLSyncKHR sync,
                        EGLint flags,
                        EGLTimeKHR timeout);

    EGLBoolean eglSignalSyncKHR(
                        EGLDisplay dpy,
                        EGLSyncKHR sync,
                        EGLenum mode);

    EGLBoolean eglGetSyncAttribKHR(
                        EGLDisplay dpy,
                        EGLSyncKHR sync,
                        EGLint attribute,
                        EGLint *value);
```
[ref](https://www.khronos.org/registry/egl/extensions/KHR/EGL_KHR_reusable_sync.txt)
# attach surface buffer to FBO
The follow code slice draw whole screen to FBO which backend is a surface buffer
```
sp<IGraphicBufferProducer> producer;
sp<IGraphicBufferConsumer> consumer;
BufferQueue::createBufferQueue(&producer, &consumer);
IGraphicBufferProducer::QueueBufferOutput bufferOutput;
sp<CpuConsumer> cpuConsumer = new CpuConsumer(consumer, 1);
sp<ISurfaceComposer> sf(ComposerService::getComposerService());
sp<IBinder> display(sf->getBuiltInDisplay(ISurfaceComposer::eDisplayIdMain));

sp<Surface> sur = new Surface(producer, false);
ANativeWindow* window = sur.get();
status_t result = native_window_api_connect(window, NATIVE_WINDOW_API_EGL);
err = native_window_set_buffers_dimensions(window, reqWidth, reqHeight);
err |= native_window_set_scaling_mode(window, NATIVE_WINDOW_SCALING_MODE_SCALE_TO_WINDOW);
err |= native_window_set_buffers_format(window, HAL_PIXEL_FORMAT_RGBA_8888);
err |= native_window_set_usage(window, usage);
ANativeWindowBuffer* buffer;
result = native_window_dequeue_buffer_and_wait(window,  &buffer);
EGLImageKHR image = eglCreateImageKHR(mEGLDisplay, EGL_NO_CONTEXT,
        EGL_NATIVE_BUFFER_ANDROID, buffer, NULL);

glGenTextures(1, &tname);
glBindTexture(GL_TEXTURE_2D, tname);
glEGLImageTargetTexture2DOES(GL_TEXTURE_2D, (GLeglImageOES)image);

// create a Framebuffer Object to render into
glGenFramebuffers(1, &name);
glBindFramebuffer(GL_FRAMEBUFFER, name);
glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, tname, 0);
*status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
//rendring to FBO...                        
```
# EGLImage
```
MALI_IMPL EGLImageKHR eglCreateImageKHR(EGLDisplay display, EGLContext context, EGLenum target, EGLClientBuffer buffer,
        const EGLint *attrib_list)
{
    heap = &dpy->common_ctx->default_heap;
    new_img = cmem_hmem_heap_alloc(heap, sizeof(*new_img), CMEM_ALIGNMENT_DEFAULT_LOG2);
        res = dpy->winsys->get_native_buffer(dpy->winsys_data, target, NULL, buffer, &color_buffer);
    return new_img;
}
/*android/winsys/jbmr1/mali_egl_winsys_android.cpp*/
static EGLint get_native_buffer( egl_winsys_display *dpy, EGLenum type, EGLConfig config,
                                 EGLClientBuffer native_buffer, egl_color_buffer **color_buffer)
{
        android_native_buffer_t *buffer = (android_native_buffer_t *)native_buffer;
        bres = winsysp_native_buffer_validate(buffer, &planes, &format);
        cb = egl_color_buffer_wrap_external_planar( dpy->egl_dpy, &planes, buffer->width, buffer->height,
                                    config, format, EGL_FALSE, winsysp_color_buffer_destructor);
        /* Reference the native buffer */
        buffer->common.incRef(&buffer->common);
}                                    

```