XBMC通过网络插件可以实现视频网站的浏览，所以将XBMC移植到VR设备上，可以通过插件来看主流的视频网站
# XBMCOnFrameAvailableListener
```
public class XBMCOnFrameAvailableListener
  implements SurfaceTexture.OnFrameAvailableListener
{
  private void signalNewFrame(SurfaceTexture paramSurfaceTexture)
  {
    monitorenter;
    try
    {
      _onFrameAvailable(paramSurfaceTexture);
      monitorexit;
      return;
    }
    finally
    {
      localObject = finally;
      monitorexit;
    }
    throw localObject;
  }

  native void _onFrameAvailable(SurfaceTexture paramSurfaceTexture);

  public void onFrameAvailable(SurfaceTexture paramSurfaceTexture)
  {
    signalNewFrame(paramSurfaceTexture);
  }
}
```