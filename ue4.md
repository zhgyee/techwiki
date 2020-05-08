# IHeadMountedDisplayModule
load plugin module and create HMDDisplay via CreateHeadMountedDisplay
```
/**
 * Test to see whether HMD is connected.  Used to guide which plug-in to select.
 */
virtual bool IsHMDConnected() { return false; }

/**
 * Get index of graphics adapter where the HMD was last connected
 */
virtual int32 GetGraphicsAdapter() { return -1; }

/**
 * Get name of audio input device where the HMD was last connected
 */
virtual FString GetAudioInputDevice() { return FString(); }

/**
 * Get name of audio output device where the HMD was last connected
 */
virtual FString GetAudioOutputDevice() { return FString(); }

/**
 * Attempts to create a new head tracking device interface
 *
 * @return	Interface to the new head tracking device, if we were able to successfully create one
 */
virtual TSharedPtr< class IHeadMountedDisplay, ESPMode::ThreadSafe > CreateHeadMountedDisplay() = 0;

```
# HeadMountedDisplay
Engine/Source/Runtime/HeadMountedDisplay
```
/**
 * Calculates the FOV, based on the screen dimensions of the device. Original FOV is passed as params.
 */
virtual void	GetFieldOfView(float& InOutHFOVInDegrees, float& InOutVFOVInDegrees) const = 0;

/**
 * If the HMD supports positional tracking via a sensor, this returns the frustum properties (all in game-world space) of the sensor.
 * Returns false, if the sensor at the specified index is not available.
 */
virtual bool	GetTrackingSensorProperties(uint8 InSensorIndex, FVector& OutOrigin, FQuat& OutOrientation, float& OutHFOV, float& OutVFOV, float& OutCameraDistance, float& OutNearPlane, float& OutFarPlane) const { return false; }

/**
 * Accessors to modify the interpupillary distance (meters)
 */
virtual void	SetInterpupillaryDistance(float NewInterpupillaryDistance) = 0;
virtual float	GetInterpupillaryDistance() const = 0;
/**
 * Apply the orientation of the headset to the PC's rotation.
 * If this is not done then the PC will face differently than the camera,
 * which might be good (depending on the game).
 */
virtual void ApplyHmdRotation(class APlayerController* PC, FRotator& ViewRotation) = 0;

/**
 * Apply the orientation and position of the headset to the Camera.
 */
virtual bool UpdatePlayerCamera(FQuat& CurrentOrientation, FVector& CurrentPosition) = 0;

/**
 * Gets the scaling factor, applied to the post process warping effect
 */
virtual float GetDistortionScalingFactor() const { return 0; }

/**
 * Gets the offset (in clip coordinates) from the center of the screen for the lens position
 */
virtual float GetLensCenterOffset() const { return 0; }

/**
 * Gets the barrel distortion shader warp values for the device
 */
virtual void GetDistortionWarpValues(FVector4& K) const  { }

/**
 * Returns 'false' if chromatic aberration correction is off.
 */
virtual bool IsChromaAbCorrectionEnabled() const = 0;

/**
 * Gets the chromatic aberration correction shader values for the device.
 * Returns 'false' if chromatic aberration correction is off.
 */
virtual bool GetChromaAbCorrectionValues(FVector4& K) const  { return false; }

/**
 * Exec handler to allow console commands to be passed through to the HMD for debugging
 */
virtual bool Exec(UWorld* InWorld, const TCHAR* Cmd, FOutputDevice& Ar) = 0;

/**
 * Returns current position scale of HMD.
 */
virtual FVector GetPositionScale3D() const { return FVector::ZeroVector; }

/**
* @return true if a hidden area mesh is available for the device.
*/
virtual bool HasHiddenAreaMesh() const { return false; }

/**
* @return true if a visible area mesh is available for the device.
*/
virtual bool HasVisibleAreaMesh() const { return false; }

/**
* Optional method to draw a view's hidden area mesh where supported.
* This can be used to avoid rendering pixels which are not included as input into the final distortion pass.
*/
virtual void DrawHiddenAreaMesh_RenderThread(class FRHICommandList& RHICmdList, EStereoscopicPass StereoPass) const {};

/**
* Optional method to draw a view's visible area mesh where supported.
* This can be used instead of a full screen quad to avoid rendering pixels which are not included as input into the final distortion pass.
*/
virtual void DrawVisibleAreaMesh_RenderThread(class FRHICommandList& RHICmdList, EStereoscopicPass StereoPass) const {};

virtual void DrawDistortionMesh_RenderThread(struct FRenderingCompositePassContext& Context, const FIntPoint& TextureSize) {}

/**
 * This method is called when playing begins. Useful to reset all runtime values stored in the plugin.
 */
virtual void OnBeginPlay(FWorldContext& InWorldContext) {}

/**
 * This method is called when playing ends. Useful to reset all runtime values stored in the plugin.
 */
virtual void OnEndPlay(FWorldContext& InWorldContext) {}

/**
 * This method is called when new game frame begins (called on a game thread).
 */
virtual bool OnStartGameFrame( FWorldContext& WorldContext ) { return false; }

/**
 * This method is called when game frame ends (called on a game thread).
 */
virtual bool OnEndGameFrame( FWorldContext& WorldContext ) { return false; }

virtual bool NeedsUpscalePostProcessPass()  { return false; }
	
```
## Android OpenGL
```
bool PlatformBlitToViewport( FPlatformOpenGLDevice* Device, const FOpenGLViewport& Viewport, uint32 BackbufferSizeX, uint32 BackbufferSizeY, bool bPresent,bool bLockToVsync, int32 SyncInterval )
{
	if (bPresent && Viewport.GetCustomPresent())
	{
		bPresent = Viewport.GetCustomPresent()->Present(SyncInterval);
	}
	if (bPresent)
	{
		AndroidEGL::GetInstance()->SwapBuffers();
	}
	return bPresent;
}
```
call FRHICustomPresent implementor to present
## FRHICustomPresent
```
class FRHICustomPresent : public FRHIResource
{
public:
	explicit FRHICustomPresent(FRHIViewport* InViewport) 
		: FRHIResource(true)
		, ViewportRHI(InViewport) 
	{
	}
	
	virtual ~FRHICustomPresent() {} // should release any references to D3D resources.
	
	// Called when viewport is resized.
	virtual void OnBackBufferResize() = 0;

	// @param InOutSyncInterval - in out param, indicates if vsync is on (>0) or off (==0).
	// @return	true if normal Present should be performed; false otherwise. If it returns
	// true, then InOutSyncInterval could be modified to switch between VSync/NoVSync for the normal Present.
	virtual bool Present(int32& InOutSyncInterval) = 0;

	// Called when rendering thread is acquired
	virtual void OnAcquireThreadOwnership() {}
	// Called when rendering thread is released
	virtual void OnReleaseThreadOwnership() {}

protected:
	// Weak reference, don't create a circular dependency that would prevent the viewport from being destroyed.
	FRHIViewport* ViewportRHI;
};
```
# GearVR
src:Engine/Plugins/Runtime/GearVR/
## GearVR
```
FGearVR
	vrapi_Initialize
	vrapi_DefaultHeadModelParms
	vrapi_GetPredictedDisplayTime
	vrapi_GetPredictedTracking
	vrapi_Shutdown
```
## GearVRRender
```
FCustomPresent
	vrapi_EnterVrMode
	vrapi_CreateTextureSwapChain
	vrapi_GetTextureSwapChainHandle
	vrapi_SubmitFrame
	vrapi_DestroyTextureSwapChain
	vrapi_LeaveVrMode
```
