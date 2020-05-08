# camera
Usually cameras render directly to screen, but for some effects it is useful to make a camera render into a texture. This is done by creating a *RenderTexture* object and setting it as targetTexture on the camera. The camera will then render into that texture. 
When targetTexture is null, camera renders to screen.
## CameraEvent
* AfterEverything	After camera has done rendering everything.
* 事件可以参考下图PipeLine上的绿点
* OnPostRender	OnPostRender is called after a camera has finished rendering the scene.
* OnPreCull	OnPreCull is called before a camera culls the scene.
* OnPreRender	OnPreRender is called before a camera starts rendering the scene.
* OnRenderImage	OnRenderImage is called after all rendering is complete to render image.
* OnRenderObject	OnRenderObject is called after camera has rendered the scene.
* OnWillRenderObject	OnWillRenderObject is called for each camera if the object is visible.

## Camera.onPreCull
OnPreCull is called before a camera culls the scene.

Culling determines which objects are visible to the camera. OnPreCull is called just before this process. 
This message is sent to all scripts attached to the camera.

If you want to change camera's viewing parameters (e.g. fieldOfView or just transform), 
this is the place to do it. Visibility of scene objects will be determined based on camera's parameters after OnPreCull.

## Camera.projectionMatrix
[custom projection](https://docs.unity3d.com/ScriptReference/Camera-projectionMatrix.html)
```
Matrix4x4 m = PerspectiveOffCenter(left, right, bottom, top, cam.nearClipPlane, cam.farClipPlane);
```
