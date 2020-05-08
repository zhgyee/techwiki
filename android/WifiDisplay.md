#exynos
```
SurfaceFlinger			doComposition
HWC						ExynosVirtualDisplay::set-->Overlay Layers--(set)-->
driver					decon1--(wb to out buffer)-->
HWC						ExynosVirtualDisplay-->
VirtualDisplaySurface	queue out buffer
WifiDisplaySource		SurfaceTexture
```
