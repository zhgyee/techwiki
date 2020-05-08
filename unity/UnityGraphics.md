# command buffer
Command buffers hold list of rendering commands ("set render target, draw mesh, ..."). 
* They can be set to execute at various points during camera rendering (see Camera.AddCommandBuffer)(public void AddCommandBuffer(Rendering.CameraEvent evt, Rendering.CommandBuffer buffer);), 
* light rendering (see Light.AddCommandBuffer) (public void AddCommandBuffer(Rendering.LightEvent evt, Rendering.CommandBuffer buffer);)
* or be executed immediately (see Graphics.ExecuteCommandBuffer).
 
其中CameraEvent和LightEvent是pipeline中可以扩展的事件

![](https://docs.unity3d.com/uploads/SL/CameraRenderFlowCmdBuffers.svg)

## CommandBuffer.IssuePluginEvent
通过commandbuffer向native plugin发送用户定义事件。扩展性比较强，如camera中通过issuePluginEvent可以调用native graphics相关的扩展。

# Graphics Device
A plugin can access generic graphics device functionality by getting the IUnityGraphics interface. In earlier versions of Unity a UnitySetGraphicsDevice function had to be exported in order to receive notification about events on the graphics device. Starting with Unity 5.2 the new IUnityGraphics interface (found in IUnityGraphics.h) provides a way to register a callback.
```
// Unity plugin load event
extern "C" void UNITY_INTERFACE_EXPORT UNITY_INTERFACE_API
    UnityPluginLoad(IUnityInterfaces* unityInterfaces)
{
    s_UnityInterfaces = unityInterfaces;
    s_Graphics = unityInterfaces->Get<IUnityGraphics>();
        
    s_Graphics->RegisterDeviceEventCallback(OnGraphicsDeviceEvent);
        
    // Run OnGraphicsDeviceEvent(initialize) manually on plugin load
    // to not miss the event in case the graphics device is already initialized
    OnGraphicsDeviceEvent(kUnityGfxDeviceEventInitialize);
}
    
// Unity plugin unload event
extern "C" void UNITY_INTERFACE_EXPORT UNITY_INTERFACE_API
    UnityPluginUnload()
{
    s_Graphics->UnregisterDeviceEventCallback(OnGraphicsDeviceEvent);
}
static void UNITY_INTERFACE_API
    OnGraphicsDeviceEvent(UnityGfxDeviceEventType eventType)
{
    switch (eventType)
    {
        case kUnityGfxDeviceEventInitialize:
        case kUnityGfxDeviceEventShutdown:
        case kUnityGfxDeviceEventBeforeReset:
        case kUnityGfxDeviceEventAfterReset:
    };
}
```
# GL
## GL.IssuePluginEvent
让渲染线程执行用户自定义命令，有时候用户需要在GL上下文中执行相关命令，这需要发送命令到渲染线程，然后在渲染线程中执行。
In order to do any rendering from the plugin, you should call GL.IssuePluginEvent from your script, 
which will cause your native plugin to be called from the render thread. For example, 
if you call GL.IssuePluginEvent from the camera's OnPostRender function, you'll get a plugin callback immediately after the camera has finished rendering.

# Component
Base class for everything attached to GameObjects.

Note that your code will never directly create a Component. Instead, you write script code, and attach the script to a GameObject. See Also: ScriptableObject as a way to create scripts that do not attach to any GameObject.
## Component.GetComponent
Returns the component of Type type if the game object has one attached, null if it doesn't.

# Renderer
A renderer is what makes an object appear on the screen. Use this class to access the renderer of any object, mesh or particle system. Renderers can be disabled to make objects invisible (see enabled), and the materials can be accessed and modified through them (see material).
```
	private void CreateTextureAndPassToPlugin()
	{
		// Create a texture
		Texture2D tex = new Texture2D(256,256,TextureFormat.ARGB32,false);
		// Set point filtering just so we can see the pixels clearly
		tex.filterMode = FilterMode.Point;
		// Call Apply() so it's actually uploaded to the GPU
		tex.Apply();

		// Set texture onto our material
		GetComponent<Renderer>().material.mainTexture = tex;

		// Pass texture pointer to the plugin
		SetTextureFromUnity (tex.GetNativeTexturePtr(), tex.width, tex.height);
	}
```