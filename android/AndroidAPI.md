# wakelock
## wakelock used in chromium
```
@CalledByNative
private void applyBlock(ContentViewCore contentViewCore) {
    assert mKeepScreenOnView == null;
    ViewAndroidDelegate delegate = contentViewCore.getViewAndroidDelegate();
    View anchorView = delegate.acquireAnchorView();
    mKeepScreenOnView = new WeakReference<>(anchorView);
    delegate.setAnchorViewPosition(anchorView, 0, 0, 0, 0);
    anchorView.setKeepScreenOn(true);
}
```

# 获取全局的context
```
static jobject getGlobalContext(JNIEnv *env)
{

    jclass activityThread = (*env)->FindClass(env,"android/app/ActivityThread");
    jmethodID currentActivityThread = (*env)->GetStaticMethodID(env,activityThread, "currentActivityThread", "()Landroid/app/ActivityThread;");
    jobject at = (*env)->CallStaticObjectMethod(env,activityThread, currentActivityThread);

    jmethodID getApplication = (*env)->GetMethodID(env,activityThread, "getApplication", "()Landroid/app/Application;");
    jobject context = (*env)->CallObjectMethod(env,at, getApplication);
    return context;
}
```