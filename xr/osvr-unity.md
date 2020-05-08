# Overview
* osvr unity sdk主要的功能实现在VRDisplayTracked->VRViewer->VREye->VRSurface这几个component中，其script负责与NativePlugin交互。
* VRDisplayTracked以及脚本DisplayController负责创建RenderManager以及Head组件(VRViewer/VREye)
* VREye负责视图矩阵等眼睛渲染信息，如果不使用RenderManager渲染，畸变则可以在这里添加。创建RenderTexture。
* VRSurface最主要就是调用Camera.Render()方法进行渲染。
* 渲染Targer Framebuffer是在VREye中创建的RenderTexture，Native Plugin使用RenderTexture的nativePtr(texName)

# VrViewer
## OnPreCull

```
VrViewer::OnPreCull()->VrViewer::DoRendering()->
    VrViewer::UpdateEyes()->VrEye::UpdateSurfaces()->VrSurface::Render()->Camera.Render()
                |
                V
            OsvrRenderManager.UPDATE_RENDERINFO_EVENT
```
```
// Culling determines which objects are visible to the camera. OnPreCull is called just before this process.
// This gets called because we have a camera component, but we disable the camera here so it doesn't render.
// We have the "dummy" camera so existing Unity game code can refer to a MainCamera object.
// We update our viewer and eye transforms here because it is as late as possible before rendering happens.
// OnPreRender is not called because we disable the camera here.
void OnPreCull()
{
	//leave the preview camera enabled if there is no display config
	_camera.enabled = !DisplayController.CheckDisplayStartup();

	DoRendering();

	//Sends queued-up commands in the driver's command buffer to the GPU.
	//only accessible in Unity 5.4+ API
#if !(UNITY_5_3 || UNITY_5_2 || UNITY_5_1 || UNITY_5_0 || UNITY_4_7 || UNITY_4_6)
	GL.Flush();
#endif

	// Flag that we disabled the camera
	_disabledCamera = true;
}
// The main rendering loop, should be called late in the pipeline, i.e. from OnPreCull
// Set our viewer and eye poses and render to each surface.
void DoRendering()
{
	// update poses once DisplayConfig is ready
	if (DisplayController.CheckDisplayStartup())
	{
		// update the viewer's head pose
		// currently getting viewer pose from DisplayConfig always
		UpdateViewerHeadPose(GetViewerPose(ViewerIndex));

		// each viewer updates its eye poses, viewports, projection matrices
		UpdateEyes();

	}
}
//Update the pose of each eye, then update and render each eye's surfaces
public void UpdateEyes()
{
	if (DisplayController.UseRenderManager)
	{
		//Update RenderInfo
		GL.IssuePluginEvent(DisplayController.RenderManager.GetRenderEventFunction(), OsvrRenderManager.UPDATE_RENDERINFO_EVENT);
	}
	else
	{
		DisplayController.UpdateClient();
	}
		
	for (uint eyeIndex = 0; eyeIndex < EyeCount; eyeIndex++)
	{                   
		//update the eye pose
		VREye eye = Eyes[eyeIndex];

		if (DisplayController.UseRenderManager)
		{ 
			//get eye pose from RenderManager                     
			eye.UpdateEyePose(DisplayController.RenderManager.GetRenderManagerEyePose((byte)eyeIndex));
		}
		else
		{
			//get eye pose from DisplayConfig
			eye.UpdateEyePose(_displayController.DisplayConfig.GetViewerEyePose(ViewerIndex, (byte)eyeIndex));
		}                       
		// update the eye's surfaces, includes call to Render
		eye.UpdateSurfaces();                   
	}
}
//VrEye.cs
//For each Surface, update viewing parameters and render the surface
public void UpdateSurfaces()
{
	//for each surface
	for (uint surfaceIndex = 0; surfaceIndex < SurfaceCount; surfaceIndex++)
	{
		//get the eye's surface
		VRSurface surface = Surfaces[surfaceIndex];

		OSVR.ClientKit.Viewport viewport;
		OSVR.ClientKit.Matrix44f projMatrix;

		//get viewport from ClientKit and set surface viewport
		if (Viewer.DisplayController.UseRenderManager)
		{
			viewport = Viewer.DisplayController.RenderManager.GetEyeViewport((int)EyeIndex);
			surface.SetViewportRect(Math.ConvertViewportRenderManager(viewport));

			//get projection matrix from RenderManager and set surface projection matrix
			surface.SetProjectionMatrix(Viewer.DisplayController.RenderManager.GetEyeProjectionMatrix((int)EyeIndex));
	   
			surface.Render();
		}
		else
		{
...
		}                           

	}
}
//VrSurface.cs
//Render the camera
public void Render()
{
	Camera.targetTexture = RenderToTexture;
	Camera.Render();
	//Sends queued-up commands in the driver's command buffer to the GPU.
	//only accessible in Unity 5.4+ API
#if !(UNITY_5_3 || UNITY_5_2 || UNITY_5_1 || UNITY_5_0 || UNITY_4_7 || UNITY_4_6)
	GL.Flush();
#endif
}
```
## EndOfFrame - couroutine

```
EndOfFrame
    ->OsvrRenderManager.RENDER_EVENT
        --Native Plugin bind framebuffer to draw
        --pass the color buffer to lowlevel RenderManager for ATW etc

// This couroutine is called every frame.
IEnumerator EndOfFrame()
{
    while (true)
    {                  
        yield return new WaitForEndOfFrame();
        if (DisplayController.UseRenderManager && DisplayController.CheckDisplayStartup())
        {
            // Issue a RenderEvent, which copies Unity RenderTextures to RenderManager buffers
            GL.Viewport(_emptyViewport);
            GL.Clear(false, true, Camera.backgroundColor);                      
            GL.IssuePluginEvent(DisplayController.RenderManager.GetRenderEventFunction(), OsvrRenderManager.RENDER_EVENT); 
            if(DisplayController.showDirectModePreview)
            {
                Camera.Render();
            } 
        }
        //if we disabled the dummy camera, enable it here
        if (_disabledCamera)
        {
            Camera.enabled = true;
            _disabledCamera = false;
        }
        //Sends queued-up commands in the driver's command buffer to the GPU.
        //only accessible in Unity 5.4+ API
#if !(UNITY_5_3 || UNITY_5_2 || UNITY_5_1 || UNITY_5_0 || UNITY_4_7 || UNITY_4_6)
    GL.Flush();
#endif
    }
} 
```
# DisplayControl
```
DisplayControl
    +VRViewers
    +VREyes
        +VrSurface
            +Camera
                +RenderTexture
```

```
//*This class is responsible for creating stereo rendering in a scene, and updating viewing parameters
// throughout a scene's lifecycle. 
// The number of viewers, eyes, and surfaces, as well as viewports, projection matrices,and distortion 
// paramerters are obtained from OSVR via ClientKit.
// 
// DisplayController creates VRViewers and VREyes as children. Although VRViewers and VREyes are siblings
// in the scene hierarchy, conceptually VREyes are indeed children of VRViewers. The reason they are siblings
// in the Unity scene is because GetViewerEyePose(...) returns a pose relative to world space, not head space.
//
// In this implementation, we are assuming that there is exactly one viewer and one surface per eye.
//*/
public class DisplayController : MonoBehaviour {
	//Use this for initialization
	void Start() {

	}
	//Update is called once per frame
    void Update()
    {

    }
    void OnPreCull() {

    }
    void OnPreRender();
    void OnPostRender();

}
```
```
Update()
	SetupDisplay();
		SetupRenderManager();
        //Set Unity player resolution
        SetResolution();

        //create scene objects 
        CreateHeadAndEyes();
        //create RenderBuffers in RenderManager
        RenderManager.ConstructBuffers();                          
        SetRenderParams();
```
# RenderManager
## render plugin event
```
// UnityRenderEvent
// This will be called for GL.IssuePluginEvent script calls; eventID will
// be the integer passed to IssuePluginEvent.
/// @todo does this actually need to be exported? It seems like
/// GetRenderEventFunc returning it would be sufficient...
void UNITY_INTERFACE_API OnRenderEvent(int eventID) {
    switch (eventID) {
    // Call the Render loop
    case kOsvrEventID_Render:
        DoRender();
        break;
    case kOsvrEventID_Shutdown:
        break;
    case kOsvrEventID_Update:
        UpdateRenderInfo();
        break;
    case kOsvrEventID_SetRoomRotationUsingHead:
        SetRoomRotationUsingHead();
        break;
    case kOsvrEventID_ClearRoomToWorldTransform:
        ClearRoomToWorldTransform();
        break;
    default:
        break;
}
```
## UpdateRenderInfo
get render info from Native RenderManager
```
void UpdateRenderInfo() {
    s_renderInfo = s_render->GetRenderInfo(s_renderParams);
}
```
## DoRender
call PresentRenderBuffers to render to Native
```
inline void DoRender() {
    for (int i = 0; i < n; ++i) {
        RenderViewOpenGL(s_renderInfo[i], s_frameBuffer,
                         s_renderBuffers[i].OpenGL->colorBufferName, i);
    }
    // Send the rendered results to the screen
    if (!s_render->PresentRenderBuffers(s_renderBuffers, s_renderInfo)) {
        DebugLog("PresentRenderBuffers() returned false, maybe because "
                 "it was asked to quit");
    }
}
// RenderViewOpenGL bind framebuffer to texture color buffer created by ConstructBuffers
inline void RenderViewOpenGL(
    const osvr::renderkit::RenderInfo &ri, //< Info needed to render
    GLuint frameBufferObj, //< Frame buffer object to bind our buffers to
    GLuint colorBuffer,    //< Color buffer to render into
    int eyeIndex) {
    // Render to our framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, frameBufferObj);
    // Set color and depth buffers for the frame buffer
    glFramebufferTexture(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, colorBuffer, 0);  
    //...
}  
```
## render buffer creation
render buffer created by DisplayController, and used at doRender()
```
void DisplayController::Update()
{
    // sometimes it takes a few frames to get a DisplayConfig from ClientKit
    // keep trying until we have initialized
    if (!_displayConfigInitialized)
    {
        SetupDisplay();
    }
}
// Get a DisplayConfig object from the server via ClientKit.
// Setup stereo rendering with DisplayConfig data.
void SetupDisplay()
{
    SetupRenderManager();
    //Set Unity player resolution
    SetResolution();

    //create scene objects 
    CreateHeadAndEyes();
    //create RenderBuffers in RenderManager
    if(UseRenderManager && RenderManager != null)
    {
        RenderManager.ConstructBuffers();
    }
    SetRenderParams();
}
//Create and Register RenderBuffers in RenderManager
//Called after RM is created and after Unity RenderTexture's are created and assigned via SetEyeColorBuffer
public int ConstructBuffers()
{
    return ConstructRenderBuffers();
}
//native plugin
OSVR_ReturnCode UNITY_INTERFACE_API ConstructRenderBuffers()
|
V
inline OSVR_ReturnCode ConstructBuffersOpenGL(int eye) {
    glGenFramebuffers(1, &s_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, s_frameBuffer);
    GLuint leftEyeColorBuffer = 0;
    glGenRenderbuffers(1, &leftEyeColorBuffer);
    osvr::renderkit::RenderBuffer rb;
    rb.OpenGL = new osvr::renderkit::RenderBufferOpenGL;
    rb.OpenGL->colorBufferName = leftEyeColorBuffer;
    s_renderBuffers.push_back(rb);
    // "Bind" the newly created texture : all future texture
    // functions will modify this texture glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, leftEyeColorBuffer);

    // Give an empty image to OpenGL ( the last "0" means "empty" )
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB,
                 static_cast<GLsizei>(s_renderInfo[eye].viewport.width),
                 static_cast<GLsizei>(s_renderInfo[eye].viewport.height), 0,
                 GL_RGB, GL_UNSIGNED_BYTE, &leftEyeColorBuffer);
}

```
## texture rendering
```
IEnumerator Start()
{
        SetUnityStreamingAssetsPath(Application.streamingAssetsPath);

        CreateTextureAndPassToPlugin();
        yield return StartCoroutine("CallPluginAtEndOfFrames");
}
|
V
private void CreateTextureAndPassToPlugin()
{
    // Create a texture
    Texture2D tex = new Texture2D(256,256,TextureFormat.ARGB32,false);
    // Set point filtering just so we can see the pixels clearly
    tex.filterMode = FilterMode.Point;
    // Call Apply() so it's actually uploaded to the GPU
    tex.Apply();

    // Set texture onto our matrial
    GetComponent<Renderer>().material.mainTexture = tex;

    // Pass texture pointer to the plugin
#if UNITY_GLES_RENDERER
    SetTextureFromUnity (tex.GetNativeTexturePtr(), tex.width, tex.height);
#else
    SetTextureFromUnity (tex.GetNativeTexturePtr());
#endif
}

```
## VrSurface
```
//set the render texture that this camera will render into
//pass the native hardware pointer to the UnityRenderingPlugin for use in RenderManager
public void SetRenderTexture(RenderTexture rt)
{
    RenderToTexture = rt;
    Camera.targetTexture = RenderToTexture;
    RenderTexture.active = RenderToTexture;
    
    //Set the native texture pointer so we can access this texture from the plugin
    Eye.Viewer.DisplayController.RenderManager.SetEyeColorBuffer(RenderToTexture.GetNativeTexturePtr(), (int)Eye.EyeIndex);
}
```