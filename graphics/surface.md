# SW draw
```
public Canvas lockCanvas(Rect inOutDirty)
public void unlockCanvasAndPost(Canvas canvas)
```
# HW draw
```
    public Canvas lockHardwareCanvas() {
        synchronized (mLock) {
            checkNotReleasedLocked();
            if (mHwuiContext == null) {
                mHwuiContext = new HwuiContext();
            }
            return mHwuiContext.lockCanvas(
                    nativeGetWidth(mNativeObject),
                    nativeGetHeight(mNativeObject));
        }
    }
    public void unlockCanvasAndPost(Canvas canvas) {
        synchronized (mLock) {
            checkNotReleasedLocked();

            if (mHwuiContext != null) {
                mHwuiContext.unlockAndPost(canvas);
            } else {
                unlockSwCanvasAndPost(canvas);
            }
        }
    }
```