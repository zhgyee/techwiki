# Unity Google VR Video Async Reprojection
## What is Video Async Reprojection?

Async Reprojection Video is a layer (referred to as an “external surface”) that an application can use to feed video frames directly into the async reprojection system. The main advantages to using the API are:

* Without the API, the video is sampled once to render it into the app’s color buffer, then the color buffer is sampled again to perform distortion correction. This introduces **double sampling** artifacts. The external surface passes video directly to the EDS compositor, so it’s only sampled once, thus improving visual quality of the video.
* When using the external surface API, video frame rate is decoupled from the app frame rate. The application can take 1 second to render a new frame and the only result is that the user will see black bars when they move their head, the video will keep playing normally. This should significantly reduce dropped video frames, and maintain AV sync
* The application can mark that it wants to playback DRM video, and the API will create a protected path that shows protected video and maintains Async Reprojection frame rate.

## sample
[see unit code book](UnityCodebook.md)

# Front buffer关闭MSAA
The Android EGL code pushes in
multisample flags in eglChooseConfig() if the user has selected the "force 4x MSAA" option
in settings. Using a multisampled front buffer is completely wasted for time warp
rendering.    
It is important to select the EGLConfig manually
without using eglChooseConfig() to make sure the front buffer is not multisampled.

# Frame Timing
it is very important that both eyes use a
sensor state that is predicted for the exact same display time, so both eyes can be
displayed at the same time without causing **intra frame motion judder**. While the predicted
orientation can be updated for each eye, the position must remain the same for both eyes,
or the position would seem to judder "backwards in time" if a frame is dropped.

# 造成显示撕裂问题的原因
* 关键路径线程（中断处理、内核work、内核线程、mali ddk处理线程、timewarp线程、vsync线程等）优先级不高，导致调度不及时，要设成**实时优先级**
* 内核日志打印优先级，如果打印到串口，则至少有10ms delay，需要将所有的内核log设置到quite级别
* GPU CPU使用率过高，需要看下GPU使用率，如果超过90%，则有可能会在显示周期内绘制不完，造成撕裂
* 带宽占用率过高，如果内存带宽占用超过50%(7420平台)，则有可能导致实时任务被delay。一般情况下GPU绘制与Camera或video同时使用的时候，GPU的带宽有可能会被camera或video占用，导致GPU被delay
* GPU驱动是否正常，用通用的GPU跑分软件验证是否某些渲染是否正常。
* 应用程序使用GL不当，如大量的texture缓存，过多的overdraw等导致的无用的GPU资源浪费

# ATW对帧率的影响
vrlib0.5中，ATW机制约束上层帧率，上层绘制完成后，交给atw warptoscreen，为了降低时延，会等待当前帧被采用做timewarp，但这样会浪费部分cpu time，导致非满帧的情况下帧率上不去，
目前的解决方案是判断当前帧的draw time，如果绘制已超过1个vsync，则不使用前面所述的同步机制，让绘制全速跑，这样来提高帧率。

# “combined eye” frustum
Even without API support though(multi-view API), if the app knows it’s doing stereo rendering, it can eliminate a double-traversal of its internal scene representation. Apps and engines usually build command stream data structures that can be executed by a render thread. Instead of building a command stream for each eye, it’s simple to build a single one that will work for both eyes. Each eye with it’s own view and projection transform. You can still do frustum culling during the traversal. You just need to use a “combined eye” frustum that contains both of the eye frusta.

![projection1](/uploads/a10ed56ae0f61b7ae81a3898a6467c2a/projection1.jpg)
![projection2](/uploads/eb6c34d38e295887ceb61100ccc64acd/projection2.jpg)

That's what I did for the Oculus VRDevice in Unity to get the combined culling matrix: 
```
float eyePullBack = (0.5f * separation) / tanf(Deg2Rad(0.5f * m_Fov));
view[14] -= eyePullBack;
proj.SetPerspective( m_Fov, m_Aspect, m_Camera->GetNear() + eyePullBack, m_Camera->GetFar() + eyePullBack);
```
Changing the projection as well as just translating the view also takes care of correctly setting the near & far planes ( doesn't require infinite far plane)

# projection generate
```
renderer->ProjectionMatrix = ovrMatrix4f_CreateProjectionFov(
									fov,
									fov,
									0.0f, 0.0f, 1.0f, 0.0f );

// Returns a projection matrix based on the given FOV.
static inline ovrMatrix4f ovrMatrix4f_CreateProjectionFov( const float fovDegreesX, const float fovDegreesY,
												const float offsetX, const float offsetY, const float nearZ, const float farZ )
{
	const float halfWidth = nearZ * tanf( fovDegreesX * ( VRAPI_PI / 180.0f * 0.5f ) );
	const float halfHeight = nearZ * tanf( fovDegreesY * ( VRAPI_PI / 180.0f * 0.5f ) );

	const float minX = offsetX - halfWidth;
	const float maxX = offsetX + halfWidth;

	const float minY = offsetY - halfHeight;
	const float maxY = offsetY + halfHeight;

	return ovrMatrix4f_CreateProjection( minX, maxX, minY, maxY, nearZ, farZ );
}										
```
# view matrix generate
```
    ivrGetHMDPose( instance , orient , pos , fov);

    ovrQuatf orentation = {orient.x , orient.y , orient.z , orient.w} ;
    ovrVector3f position = {pos.x , pos.y , pos.z};
    float ipd = info.ipd;
	// Calculate the view matrix.
	const ovrMatrix4f centerEyeViewMatrix = vrapi_GetCenterEyeViewMatrix( orentation , position , NULL );

	ovrMatrix4f eyeViewMatrix[2];
	eyeViewMatrix[0] = vrapi_GetEyeViewMatrix( ipd , &centerEyeViewMatrix, 0 );
	eyeViewMatrix[1] = vrapi_GetEyeViewMatrix( ipd , &centerEyeViewMatrix, 1 );
```
```
// Utility function to get the center eye view matrix.
// Pass in NULL for 'input' if there is no additional controller input.
static inline ovrMatrix4f vrapi_GetCenterEyeViewMatrix(	const ovrQuatf orentation,
														const ovrVector3f position,
														const ovrMatrix4f * input )
{
	const ovrMatrix4f centerEyeTransform = vrapi_GetCenterEyeTransform( orentation, position, input );
	return ovrMatrix4f_Inverse( &centerEyeTransform );
}

// Utility function to get the eye view matrix based on the center eye view matrix and the IPD.
static inline ovrMatrix4f vrapi_GetEyeViewMatrix(	const float ipd,
													const ovrMatrix4f * centerEyeViewMatrix,
													const int eye )
{
	const float eyeOffset = ( eye ? -0.5f : 0.5f ) * ipd;
	const ovrMatrix4f eyeOffsetMatrix = ovrMatrix4f_CreateTranslation( eyeOffset, 0.0f, 0.0f );
	return ovrMatrix4f_Multiply( &eyeOffsetMatrix, centerEyeViewMatrix );
}
```

# TexCoordsTanAnglesMatrix
```
	renderer->TexCoordsTanAnglesMatrix = ovrMatrix4f_TanAngleMatrixFromProjection( &renderer->ProjectionMatrix );
// Convert a standard projection matrix into a TexCoordsFromTanAngles matrix for
// the primary time warp surface.
static inline ovrMatrix4f ovrMatrix4f_TanAngleMatrixFromProjection( const ovrMatrix4f * projection )
{
	/*
		A projection matrix goes from a view point to NDC, or -1 to 1 space.
		Scale and bias to convert that to a 0 to 1 space.

		const ovrMatrix3f m =
		{ {
			{ projection->M[0][0],                0.0f, projection->M[0][2] },
			{                0.0f, projection->M[1][1], projection->M[1][2] },
			{                0.0f,                0.0f,               -1.0f }
		} };
		// Note that there is no Y-flip because eye buffers have 0,0 = left-bottom.
		const ovrMatrix3f s = ovrMatrix3f_CreateScaling( 0.5f, 0.5f );
		const ovrMatrix3f t = ovrMatrix3f_CreateTranslation( 0.5f, 0.5f );
		const ovrMatrix3f r0 = ovrMatrix3f_Multiply( &s, &m );
		const ovrMatrix3f r1 = ovrMatrix3f_Multiply( &t, &r0 );
		return r1;

		clipZ = ( z * projection[2][2] + projection[2][3] ) / ( projection[3][2] * z )
		z = projection[2][3] / ( clipZ * projection[3][2] - projection[2][2] )
		z = ( projection[2][3] / projection[3][2] ) / ( clipZ - projection[2][2] / projection[3][2] )
	*/
	const ovrMatrix4f tanAngleMatrix =
	{ {
		{ 0.5f * projection->M[0][0], 0.0f, 0.5f * projection->M[0][2] - 0.5f, 0.0f },
		{ 0.0f, 0.5f * projection->M[1][1], 0.5f * projection->M[1][2] - 0.5f, 0.0f },
		{ 0.0f, 0.0f, -1.0f, 0.0f },
		// Store the values to convert a clip-Z to a linear depth in the unused matrix elements.
		{ projection->M[2][2], projection->M[2][3], projection->M[3][2], 1.0f }
	} };
	return tanAngleMatrix;
}	
```

# Multi-view

Mobile SDK 1.0.3 adds multi-view rendering support. Multi-view rendering allows drawing to both eye views simultaneously, significantly reducing driver API overhead. It includes GPU optimizations for geometry processing.

Preliminary testing has shown that multi-view can provide:

25-50% reduction in CPU time consumed by the application
5% reduction in GPU time on the ARM Mali
5%-10% reduction in power draw
Obviously the freed up CPU time could be used to issue more draw calls. However, instead of issuing more draw calls, we recommend that applications maintain the freed up CPU time for use by the driver threads to reduce/eliminate screen tears.

While current driver implementations of multi-view primarily reduce the CPU usage, the GPU usage is not always unaffected. On the Exynos based devices, multi-view not only reduces the CPU load, but slightly reduces the GPU load by only computing the view-independent vertex attributes once for both eyes, instead of separately for each eye.

Even though there are significant savings in CPU time, these savings do not directly translate into a similar reduction in power draw. The power drawn by the CPU is only a fraction of the total power drawn by the device (which includes the GPU, memory bandwidth, display etc.).

Although all applications will have their unique set of challenges to consider, multi-view should allow most applications to lower the CPU clock frequency (CPU level) which will in turn improve power usage and the thermal envelope. However, this does not help on the Exynos based devices where CPU level 1, 2 and 3 all use the same clock frequency.

Multi-view will not be available on all Gear VR devices until driver and system updates become available.