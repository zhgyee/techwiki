#IWindow
interfaces called by Windowmanager
```
executeCommand(String, String, ParcelFileDescriptor)
resized(Rect, Rect, Rect, Rect, Rect, Rect, boolean, Configuration)
moved(int, int)
dispatchAppVisibility(boolean)
dispatchGetNewSurface()
windowFocusChanged(boolean, boolean)
closeSystemDialogs(String)
dispatchWallpaperOffsets(float, float, float, float, boolean)
dispatchWallpaperCommand(String, int, int, int, Bundle, boolean)
dispatchDragEvent(DragEvent)
dispatchSystemUiVisibilityChanged(int, int, int, int)
onAnimationStarted(int)
onAnimationStopped()
dispatchWindowShown()
```
route to activity object
```
WindowManagerServie
|	(using ibinder to find AppWindowToken)
V
AppWindowToken
|	(call to client)
V
IWindow
|	(dispatch to ViewRootImpl/WindowSession)
V
W---->ViewRootImpl
 +--->IWindowSession
```
