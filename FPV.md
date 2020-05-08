# GLRenderer14_StereoSuperSYNC
GLRenderer14_StereoSuperSYNC.java
```
public void onDrawFrame() {}
        |
        v
void GLRSuperSync::enterSuperSyncLoop(JNIEnv * env, jobject obj,jobject surfaceTexture,int exclusiveVRCore) {
    mVideoRenderer->initUpdateTexImageJAVA(env,obj,surfaceTexture);
    setAffinity(exclusiveVRCore);
    setCPUPriority(CPU_PRIORITY_GLRENDERER_STEREO_FB,"GLRenderer14_StereoSuperSYNC");
    mTelemetryReceiver->get_other_osd_data()->opengl_fps=-1.0f;
    //This will block until mFBRManager->exitDirectRenderingLoop() is called
    LOGV("entering superSync loop. GLThread will be blocked");
    mFBRManager->enterDirectRenderingLoop(env);
    LOGV("exited superSync loop. GLThread unblocked");
    mVideoRenderer->deleteUpdateTexImageJAVA(env,obj);
}    

void FBRManager::enterDirectRenderingLoop(JNIEnv* env) {
        int64_t leOffset=waitUntilVsyncStart();
        onRenderNewEyeCallback(env,RIGHT_EYE,leOffset);
        
        int64_t reOffset=waitUntilVsyncMiddle();
        onRenderNewEyeCallback(env,LEFT_EYE,reOffset);
    }
    
void GLRSuperSync::renderNewEyeCallback(JNIEnv *env, bool whichEye, int64_t offsetNS) {
    mFBRManager->startDirectRendering(whichEye,ViewPortW,ViewPortH);
    drawEye(whichEye);
    mFBRManager->stopDirectRendering(whichEye);
}    
```