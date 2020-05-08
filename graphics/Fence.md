# recommended reference
csdn-jinzhuojun
#Prevent GPU buffering using fence

The drive to win frame rate benchmark wars has led driver writers to aggressively buffer drawing commands, and there have even been cases where drivers ignored explicit calls to glFinish() in the name of improved “performance”.  Today’s fence primitives do appear to be reliably observed for drawing primitives, but the semantics of buffer swaps are still worryingly imprecise.  A recommended sequence of commands to synchronize with the vertical retrace and idle the GPU is:
```
SwapBuffers();
DrawTinyPrimitive();
InsertGPUFence();
BlockUntilFenceIsReached();
```
While this should always prevent excessive command buffering on any conformant driver, ***it could conceivably fail to provide an accurate vertical sync timing point if the driver was transparently implementing triple buffering***.
- See more at: https://web.archive.org/web/20140719053303/http://www.altdev.co/2013/02/22/latency-mitigation-strategies/#sthash.JqdNiA89.dpuf

# create GLFence frome fd
```
if (SyncFeatures::getInstance().useWaitSync()) {
    // Create an EGLSyncKHR from the current fence.
    int fenceFd = mCurrentFence->dup();
    if (fenceFd == -1) {
        ST_LOGE("doGLFenceWait: error dup'ing fence fd: %d", errno);
        return -errno;
    }
    EGLint attribs[] = {
        EGL_SYNC_NATIVE_FENCE_FD_ANDROID, fenceFd,
        EGL_NONE
    };
    EGLSyncKHR sync = eglCreateSyncKHR(dpy,
            EGL_SYNC_NATIVE_FENCE_ANDROID, attribs);
    if (sync == EGL_NO_SYNC_KHR) {
        close(fenceFd);
        ST_LOGE("doGLFenceWait: error creating EGL fence: %#x",
                eglGetError());
        return UNKNOWN_ERROR;
    }

    // XXX: The spec draft is inconsistent as to whether this should
    // return an EGLint or void.  Ignore the return value for now, as
    // it's not strictly needed.
    eglWaitSyncKHR(dpy, sync, 0);
    EGLint eglErr = eglGetError();

    if (eglErr != EGL_SUCCESS) {
        ret = ioctl(fenceFd, SYNC_IOC_DETECT);
        if (ret<0) {
           eglDestroySyncKHR(dpy, sync);
        } else {
           eglDestroySyncKHR(dpy, sync);
           ST_LOGE("doGLFenceWait: error waiting for EGL fence: %#x",
                eglErr);
           return UNKNOWN_ERROR;
        }
    } else {
        eglDestroySyncKHR(dpy, sync);
    }
} else {
    status_t err = mCurrentFence->waitForever(
            "GLConsumer::doGLFenceWaitLocked");
    if (err != NO_ERROR) {
        ST_LOGE("doGLFenceWait: error waiting for fence: %d", err);
        return err;
    }
}

```
# create native fence from elg
```
if (SyncFeatures::getInstance().useNativeFenceSync()) {
    EGLSyncKHR sync = eglCreateSyncKHR(dpy,
            EGL_SYNC_NATIVE_FENCE_ANDROID, NULL);
    if (sync == EGL_NO_SYNC_KHR) {
        ST_LOGE("syncForReleaseLocked: error creating EGL fence: %#x",
                eglGetError());
        return UNKNOWN_ERROR;
    }
    glFlush();
    int fenceFd = eglDupNativeFenceFDANDROID(dpy, sync);
    eglDestroySyncKHR(dpy, sync);
    if (fenceFd == EGL_NO_NATIVE_FENCE_FD_ANDROID) {
        ST_LOGE("syncForReleaseLocked: error dup'ing native fence "
                "fd: %#x", eglGetError());
        return UNKNOWN_ERROR;
    }
    sp<Fence> fence(new Fence(fenceFd));
    status_t err = addReleaseFenceLocked(mCurrentTexture,
            mCurrentTextureBuf, fence);
    if (err != OK) {
        ST_LOGE("syncForReleaseLocked: error adding release fence: "
                "%s (%d)", strerror(-err), err);
        return err;
    }
}
```
# using EGL Fence
1. eglCreateSyncKHR---Create a fence for the outstanding accesses 
2. eglClientWaitSyncKHR---client should wait the fence finished

```
if (mUseFenceSync && SyncFeatures::getInstance().useFenceSync()) {
    EGLSyncKHR fence = mEglSlots[mCurrentTexture].mEglFence;
    if (fence != EGL_NO_SYNC_KHR) {
        // There is already a fence for the current slot.  We need to
        // wait on that before replacing it with another fence to
        // ensure that all outstanding buffer accesses have completed
        // before the producer accesses it.
        EGLint result = eglClientWaitSyncKHR(dpy, fence, 0, 1000000000);
        if (result == EGL_FALSE) {
            ST_LOGE("syncForReleaseLocked: error waiting for previous "
                    "fence: %#x", eglGetError());
            return UNKNOWN_ERROR;
        } else if (result == EGL_TIMEOUT_EXPIRED_KHR) {
            ST_LOGE("syncForReleaseLocked: timeout waiting for previous "
                    "fence");
            return TIMED_OUT;
        }
        eglDestroySyncKHR(dpy, fence);
    }

    // Create a fence for the outstanding accesses in the current
    // OpenGL ES context.
    fence = eglCreateSyncKHR(dpy, EGL_SYNC_FENCE_KHR, NULL);
    if (fence == EGL_NO_SYNC_KHR) {
        ST_LOGE("syncForReleaseLocked: error creating fence: %#x",
                eglGetError());
        return UNKNOWN_ERROR;
    }
    glFlush();
    mEglSlots[mCurrentTexture].mEglFence = fence;
}
```
