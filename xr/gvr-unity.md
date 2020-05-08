# scene
* GvrMain
   * Head
     * Main Camera
         * MainCamera Left
         * MainCamera Right
 * Stereo Rendner
     * Pre Render
     * Post Render


# Native Plugin interface
```
    private static extern void Start();
    private static extern void SetTextureId(int id);
    private static extern bool SetDefaultProfile(byte[] uri, int size);
    private static extern void SetUnityVersion(byte[] version_str, int version_length);
    private static extern void EnableDistortionCorrection(bool enable);
    private static extern void EnableElectronicDisplayStabilization(bool enable);
    private static extern void SetNeckModelFactor(float factor);
    private static extern void ResetHeadTracker();
    private static extern int  GetEventFlags();
    private static extern void GetProfile(float[] profile);
    private static extern void GetHeadPose(float[] pose);
    private static extern void GetViewParameters(float[] viewParams);
    private static extern void Pause();
    private static extern void Resume();
    private static extern void Stop();
```
# stereo rendering
## 初始化流程
StereoController.cs
```
  void Awake() {
    GvrViewer.Create();
    cam = GetComponent<Camera>();
    AddStereoRig();
  }
  public void AddStereoRig() {
    CreateEye(GvrViewer.Eye.Left);
    CreateEye(GvrViewer.Eye.Right);
    if (Head == null) {
      var head = gameObject.AddComponent<GvrHead>();
      // Don't track position for dynamically added Head components, or else
      // you may unexpectedly find your camera pinned to the origin.
      head.trackPosition = false;
    }
  }
  // Helper routine for creation of a stereo eye.
  private void CreateEye(GvrViewer.Eye eye) {
    string nm = name + (eye == GvrViewer.Eye.Left ? " Left" : " Right");
    GameObject go = new GameObject(nm);
    go.transform.SetParent(transform, false);
    go.AddComponent<Camera>().enabled = false;
    var GvrEye = go.AddComponent<GvrEye>();
    GvrEye.eye = eye;
    GvrEye.CopyCameraAndMakeSideBySide(this);
  }  
```
GvrView.cs
```

```
## 建立立体渲染
/// Controls one camera of a stereo pair.  Each frame, it mirrors the settings of
/// the parent mono Camera, and then sets up side-by-side stereo with
/// the view and projection matrices from the GvrViewer.EyeView and GvrViewer.Projection.
/// The render output is directed to the GvrViewer.StereoScreen render texture, either
/// to the left half or right half depending on the chosen eye.
///
/// To enable a stereo camera pair, enable the parent mono camera and set
/// GvrViewer.vrModeEnabled = true.
GvrEye.cs
```
  void OnPreCull() {
    SetupStereo(/*forceUpdate=*/false);
```
建立投影，视口，以及目标纹理
```
  private void SetupStereo(bool forceUpdate) {
    GvrViewer.Instance.UpdateState();

    bool updateValues = forceUpdate  // Being called from Start(), most likely.
        || controller.keepStereoUpdated  // Parent camera may be animating.
        || GvrViewer.Instance.ProfileChanged  // New QR code.
        || GvrViewer.Instance.StereoScreen != null
          && GvrViewer.Instance.StereoScreen.count > 1 ;  // Need to (re)assign targetTexture.
    if (updateValues) {
      // Set projection, viewport and targetTexture.
      UpdateStereoValues();
    }
```
建立双目camera
```
  public void UpdateStereoValues() {
    Matrix4x4 proj = GvrViewer.Instance.Projection(eye);
    realProj = GvrViewer.Instance.Projection(eye, GvrViewer.Distortion.Undistorted);

    CopyCameraAndMakeSideBySide(controller, proj[0, 2], proj[1, 2]);
```
```
  /// Helper to copy camera settings from the controller's mono camera.  Used in SetupStereo() and
  /// in the custom editor for StereoController.  The parameters parx and pary, if not left at
  /// default, should come from a projection matrix returned by the SDK.  They affect the apparent
  /// depth of the camera's window.  See SetupStereo().
  public void CopyCameraAndMakeSideBySide(StereoController controller,
                                          float parx = 0, float pary = 0) {
```
## 执行立体渲染

GvrPostRender.cs
```
  void OnRenderObject() {
    GvrViewer.Instance.UpdateState();
    StereoScreen stereoScreen = GvrViewer.Instance.StereoScreen;
      GvrViewer.Instance.PostRender(stereoScreen);
      //
    stereoScreen.DiscardContents();
    
```
GvrView.cs
```
  /// Presents the #StereoScreen to the device for distortion correction and display.
  /// @note This function is only used if #DistortionCorrection is set to _Native_,
  /// and it only has an effect if the device supports it.
  public void PostRender(StereoScreen stereoScreen) {
    if (NativeDistortionCorrectionSupported && stereoScreen != null && stereoScreen.IsCreated()) {
      device.PostRender(stereoScreen);
    }
  }
```
# callstack of SetTextureId
## GvrPostRender
```
  void OnRenderObject() {
    GvrViewer.Instance.UpdateState();
    var correction = GvrViewer.Instance.DistortionCorrection;
    RenderTexture stereoScreen = GvrViewer.Instance.StereoScreen;
...
    if (correction == GvrViewer.DistortionCorrectionMethod.Native
        && GvrViewer.Instance.NativeDistortionCorrectionSupported) {
      GvrViewer.Instance.PostRender(stereoScreen);//使用Native Plugin 渲染
    } else {
...
      meshMaterial.mainTexture = stereoScreen;
      meshMaterial.SetPass(0);
      Graphics.DrawMeshNow(distortionMesh, transform.position, transform.rotation);
    }
    stereoScreen.DiscardContents();
  }
```
## GvrViewer
```
  /// Presents the #StereoScreen to the device for distortion correction and display.
  /// @note This function is only used if #DistortionCorrection is set to _Native_,
  /// and it only has an effect if the device supports it.
  public void PostRender(RenderTexture stereoScreen) {
    if (NativeDistortionCorrectionSupported && stereoScreen != null && stereoScreen.IsCreated()) {
      device.PostRender(stereoScreen);
    }
  }
```
## GvrDevice
```
    public override void PostRender(RenderTexture stereoScreen) {
      SetTextureId((int)stereoScreen.GetNativeTexturePtr());
      GL.IssuePluginEvent(kRenderEvent);
    }
```