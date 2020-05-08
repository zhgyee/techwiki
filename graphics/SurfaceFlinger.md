# frametrack

`adb shell dumpsys SurfaceFlinger --latency “process_name”`

来进行查看近 120+(2秒)的frameReady状况，同时他也记录着display的Present 时间。

第一列为DesiredPresentTime,第二列为ActualyPresentTime，第三列为FrameReadyTime

# dump信息
参考
http://lee_3do.leanote.com/post/SurfaceFlinger%E7%9A%84dump%E4%BF%A1%E6%81%AF%E8%AF%A6%E8%A7%A3

http://blog.csdn.net/lee_3do/article/details/43016299

#transaction
```
SurfaceFlinger::onTransact
SurfaceFlinger::setTransactionState
SurfaceFlinger::setClientStateLocked

```

#display layer stack
每个display device都将display id做为display layer stack的值，每个surface都携带相应的display id(layer stack)来决定显示在哪个display上，
如将virtual display layer stack设置为0，则所有的surface layer(surface的layer stack默认都为0)都将显示到virtual display上面，这样可以实现截屏。
# setDisplayLayerStack
设置display层序，决定当前surface显示在哪个display上

```
android.view.SurfaceControl.setDisplayLayerStack(IBinder, int)
com.android.server.display.DisplayDevice.setLayerStackInTransactionLocked(int)
com.android.server.display.LogicalDisplay.configureDisplayInTransactionLocked(DisplayDevice, boolean)
com.android.server.display.DisplayManagerService.configureDisplayInTransactionLocked(DisplayDevice)
com.android.server.display.DisplayManagerService.performTraversalInTransactionLocked()
com.android.server.display.DisplayManagerService.performTraversalInTransactionFromWindowManagerInternal()
com.android.server.display.DisplayManagerService.LocalService.performTraversalInTransactionFromWindowManager()
com.android.server.wm.WindowManagerService.performLayoutAndPlaceSurfacesLockedInner(boolean)
com.android.server.wm.WindowManagerService.performLayoutAndPlaceSurfacesLockedLoop()
com.android.server.wm.WindowManagerService.performLayoutAndPlaceSurfacesLocked()
```
当新的surface被创建时，会添加到所有display　device上，这样所有display device显示一样的内容
```
private void performTraversalInTransactionLocked() {

    // Configure each display device.
    final int count = mDisplayDevices.size();
    for (int i = 0; i < count; i++) {
        DisplayDevice device = mDisplayDevices.get(i);
        configureDisplayInTransactionLocked(device);
        device.performTraversalInTransactionLocked();
    }
}
```
