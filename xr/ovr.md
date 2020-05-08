# API follows
## overview
```
// Setup the Java references.
ovrJava java;
java.Vm = javaVm;
java.Env = jniEnv;
java.ActivityObject = activityObject;

// Initialize the API.
const ovrInitParms initParms = vrapi_DefaultInitParms( &java );
if ( vrapi_Initialize( &initParms ) != VRAPI_INITIALIZE_SUCCESS )
{
	FAIL( "Failed to initialize VrApi!" );
	abort();
}

// Create an EGLContext for the application.
EGLContext eglContext = ;	// application's context

// Get the suggested resolution to create eye texture swap chains.
const int suggestedEyeTextureWidth = vrapi_GetSystemPropertyInt( &java, VRAPI_SYS_PROP_SUGGESTED_EYE_TEXTURE_WIDTH );
const int suggestedEyeTextureHeight = vrapi_GetSystemPropertyInt( &java, VRAPI_SYS_PROP_SUGGESTED_EYE_TEXTURE_HEIGHT );

// Allocate a texture swap chain for each eye with the application's EGLContext current.
ovrTextureSwapChain * colorTextureSwapChain[VRAPI_FRAME_LAYER_EYE_MAX];
for ( int eye = 0; eye < VRAPI_FRAME_LAYER_EYE_MAX; eye++ )
{
	colorTextureSwapChain[eye] = vrapi_CreateTextureSwapChain( VRAPI_TEXTURE_TYPE_2D, VRAPI_TEXTURE_FORMAT_8888,
																suggestedEyeTextureWidth,
																suggestedEyeTextureHeight,
																1, true );
}

// Get the suggested FOV to setup a projection matrix.
const float suggestedEyeFovDegreesX = vrapi_GetSystemPropertyFloat( &java, VRAPI_SYS_PROP_SUGGESTED_EYE_FOV_DEGREES_X );
const float suggestedEyeFovDegreesY = vrapi_GetSystemPropertyFloat( &java, VRAPI_SYS_PROP_SUGGESTED_EYE_FOV_DEGREES_Y );

// Setup a projection matrix based on the suggested FOV.
// Note that this is an infinite projection matrix for the best precision.
const ovrMatrix4f eyeProjectionMatrix = ovrMatrix4f_CreateProjectionFov( suggestedEyeFovDegreesX,
																		suggestedEyeFovDegreesY,
																		0.0f, 0.0f, VRAPI_ZNEAR, 0.0f );

// Android Activity/Surface life cycle loop.
while ( !exit )
{
	// Acquire ANativeWindow from Android Surface.

	ANativeWindow * nativeWindow = ;	// ANativeWindow for the Android Surface
	bool resumed = ;					// set to true in onResume() and set to false in onPause()

	while ( resumed && nativeWindow != NULL )
	{
		// Enter VR mode once the Android Activity is in the resumed state with a valid ANativeWindow.
		ovrModeParms modeParms = vrapi_DefaultModeParms( &java );
		modeParms.Flags |= VRAPI_MODE_FLAG_NATIVE_WINDOW;
		modeParms.Display = eglDisplay;
		modeParms.WindowSurface = nativeWindow;
		modeParms.ShareContext = eglContext;
		ovrMobile * ovr = vrapi_EnterVrMode( &modeParms );

		// Frame loop, possibly running on another thread.
		for ( long long frameIndex = 1; resumed && nativeWindow != NULL; frameIndex++ )
		{
			// Get the HMD pose, predicted for the middle of the time period during which
			// the new eye images will be displayed. The number of frames predicted ahead
			// depends on the pipeline depth of the engine and the synthesis rate.
			// The better the prediction, the less black will be pulled in at the edges.
			const double predictedDisplayTime = vrapi_GetPredictedDisplayTime( ovr, frameIndex );
			const ovrTracking baseTracking = vrapi_GetPredictedTracking( ovr, predictedDisplayTime );

			// Apply the head-on-a-stick model if there is no positional tracking.
			const ovrHeadModelParms headModelParms = vrapi_DefaultHeadModelParms();
			const ovrTracking tracking = vrapi_ApplyHeadModel( &headModelParms, &baseTracking );

			// Advance the simulation based on the predicted display time.

			// Render eye images and setup ovrFrameParms using 'ovrTracking'.
			ovrFrameParms frameParms = vrapi_DefaultFrameParms( &java, VRAPI_FRAME_INIT_DEFAULT, predictedDisplayTime, NULL );
			frameParms.FrameIndex = frameIndex;

			const ovrMatrix4f centerEyeViewMatrix = vrapi_GetCenterEyeViewMatrix( &headModelParms, &tracking, NULL );
			for ( int eye = 0; eye < VRAPI_FRAME_LAYER_EYE_MAX; eye++ )
			{
				const ovrMatrix4f eyeViewMatrix = vrapi_GetEyeViewMatrix( &headModelParms, &centerEyeViewMatrix, eye );

				const int colorTextureSwapChainIndex = frameIndex % vrapi_GetTextureSwapChainLength( colorTextureSwapChain[eye] );
				const unsigned int textureId = vrapi_GetTextureSwapChainHandle( colorTextureSwapChain[eye], colorTextureSwapChainIndex );

				// Render to 'textureId' using the 'eyeViewMatrix' and 'eyeProjectionMatrix'.
				// Insert 'fence' using eglCreateSyncKHR.

				frameParms.Layers[0].Textures[eye].ColorTextureSwapChain = colorTextureSwapChain[eye];
				frameParms.Layers[0].Textures[eye].TextureSwapChainIndex = colorTextureSwapChainIndex;
				frameParms.Layers[0].Textures[eye].TexCoordsFromTanAngles = ovrMatrix4f_TanAngleMatrixFromProjection( &eyeProjectionMatrix );
				frameParms.Layers[0].Textures[eye].HeadPose = tracking.HeadPose;
				frameParms.Layers[0].Textures[eye].CompletionFence = fence;
			}

			// Hand over the eye images to the time warp.
			vrapi_SubmitFrame( ovr, &frameParms );
		}
	}

	// Must leave VR mode when the Android Activity is paused or the Android Surface is destroyed or changed.
	vrapi_LeaveVrMode( ovr );
}

// Destroy the texture swap chains.
// Make sure to delete the swapchains before the application's EGLContext is destroyed.
for ( int eye = 0; eye < VRAPI_FRAME_LAYER_EYE_MAX; eye++ )
{
	vrapi_DestroyTextureSwapChain( colorTextureSwapChain[eye] );
}

// Shut down the API.
vrapi_Shutdown();
```
***
Main thread working
***
## init
```
vrapi_Initialize( &initParms );
```
## Create EGL context
```
ovrEgl_CreateContext( &appState.Egl, NULL );
	egl->Display = eglGetDisplay( EGL_DEFAULT_DISPLAY );
	eglInitialize( egl->Display, &egl->MajorVersion, &egl->MinorVersion );
	//choose config with EGL_WINDOW_BIT | EGL_PBUFFER_BIT
	// The pbuffer config also needs to be compatible with normal window rendering
	// so it can share textures with the window context.
	...
	egl->Context = eglCreateContext( egl->Display, egl->Config, ( shareEgl != NULL )
	egl->TinySurface = eglCreatePbufferSurface( egl->Display, egl->Config, surfaceAttribs );
	eglMakeCurrent( egl->Display, egl->TinySurface, egl->TinySurface, egl->Context )
EglInitExtensions();
	eglGetProcAddress()//SYNC procs	
```
## setup performance parameters
```
	ovrPerformanceParms perfParms = vrapi_DefaultPerformanceParms();
	perfParms.CpuLevel = CPU_LEVEL;
	perfParms.GpuLevel = GPU_LEVEL;
	perfParms.MainThreadTid = gettid();
	// Also set the renderer thread to SCHED_FIFO.
	perfParms.RenderThreadTid = ovrRenderThread_GetTid( &appState.RenderThread );	
```

## pause/resume enter/leave vrmode
```
app->Ovr = vrapi_EnterVrMode( &parms );
vrapi_LeaveVrMode( app->Ovr );
```

## Get latest sensor state, nofity render thread to draw frame and submit to sdk

```
// This is the only place the frame index is incremented, right before
// calling vrapi_GetPredictedDisplayTime().
appState.FrameIndex++;

// Get the HMD pose, predicted for the middle of the time period during which
// the new eye images will be displayed. The number of frames predicted ahead
// depends on the pipeline depth of the engine and the synthesis rate.
// The better the prediction, the less black will be pulled in at the edges.
const double predictedDisplayTime = vrapi_GetPredictedDisplayTime( appState.Ovr, appState.FrameIndex );
const ovrTracking baseTracking = vrapi_GetPredictedTracking( appState.Ovr, predictedDisplayTime );

// Apply the head-on-a-stick model if there is no positional tracking.
const ovrHeadModelParms headModelParms = vrapi_DefaultHeadModelParms();
const ovrTracking tracking = vrapi_ApplyHeadModel( &headModelParms, &baseTracking );

// Advance the simulation based on the predicted display time.
ovrSimulation_Advance( &appState.Simulation, predictedDisplayTime );

// Render the eye images on a separate thread.
ovrRenderThread_Submit( &appState.RenderThread, appState.Ovr,
		RENDER_FRAME, appState.FrameIndex, appState.MinimumVsyncs, &perfParms,
		&appState.Scene, &appState.Simulation, &tracking );
```

***
Render Thread working
***
## create framebuffers
```
	frameBuffer->Width = width;
	frameBuffer->Height = height;
	frameBuffer->Multisamples = multisamples;
	frameBuffer->UseMultiview = ( useMultiview && ( glFramebufferTextureMultiviewOVR != NULL ) ) ? true : false;

	frameBuffer->ColorTextureSwapChain = vrapi_CreateTextureSwapChain( frameBuffer->UseMultiview ? VRAPI_TEXTURE_TYPE_2D_ARRAY : VRAPI_TEXTURE_TYPE_2D, colorFormat, width, height, 1, true );
	frameBuffer->TextureSwapChainLength = vrapi_GetTextureSwapChainLength( frameBuffer->ColorTextureSwapChain );
	frameBuffer->DepthBuffers = (GLuint *)malloc( frameBuffer->TextureSwapChainLength * sizeof( GLuint ) );
	frameBuffer->FrameBuffers = (GLuint *)malloc( frameBuffer->TextureSwapChainLength * sizeof( GLuint ) );
	for ( int i = 0; i < frameBuffer->TextureSwapChainLength; i++ )
	{
		// Create the color buffer texture.
		const GLuint colorTexture = vrapi_GetTextureSwapChainHandle( frameBuffer->ColorTextureSwapChain, i );//texture created by sdk
		GLenum colorTextureTarget = frameBuffer->UseMultiview ? GL_TEXTURE_2D_ARRAY : GL_TEXTURE_2D;
		GL( glBindTexture( colorTextureTarget, colorTexture ) );

		// Create depth buffer.
		GL( glGenRenderbuffers( 1, &frameBuffer->DepthBuffers[i] ) );
		GL( glBindRenderbuffer( GL_RENDERBUFFER, frameBuffer->DepthBuffers[i] ) );
		GL( glRenderbufferStorage( GL_RENDERBUFFER, GL_DEPTH_COMPONENT24, width, height ) );
		GL( glBindRenderbuffer( GL_RENDERBUFFER, 0 ) );

		// Create the frame buffer.
		GL( glGenFramebuffers( 1, &frameBuffer->FrameBuffers[i] ) );
		GL( glBindFramebuffer( GL_DRAW_FRAMEBUFFER, frameBuffer->FrameBuffers[i] ) );
		GL( glFramebufferRenderbuffer( GL_DRAW_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, frameBuffer->DepthBuffers[i] ) );
		GL( glFramebufferTexture2D( GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, colorTexture, 0 ) );
		GL( GLenum renderFramebufferStatus = glCheckFramebufferStatus( GL_DRAW_FRAMEBUFFER ) );
		GL( glBindFramebuffer( GL_DRAW_FRAMEBUFFER, 0 ) );
	}

```
## projection transform
```
	// Setup the projection matrix.
	renderer->ProjectionMatrix = ovrMatrix4f_CreateProjectionFov(
										vrapi_GetSystemPropertyFloat( java, VRAPI_SYS_PROP_SUGGESTED_EYE_FOV_DEGREES_X ),
										vrapi_GetSystemPropertyFloat( java, VRAPI_SYS_PROP_SUGGESTED_EYE_FOV_DEGREES_Y ),
										0.0f, 0.0f, 1.0f, 0.0f );
	renderer->TexCoordsTanAnglesMatrix = ovrMatrix4f_TanAngleMatrixFromProjection( &renderer->ProjectionMatrix );

```
## render frame
```
	ovrFrameParms parms = vrapi_DefaultFrameParms( java, VRAPI_FRAME_INIT_DEFAULT, vrapi_GetTimeInSeconds(), NULL );
	parms.FrameIndex = frameIndex;
	parms.MinimumVsyncs = minimumVsyncs;
	parms.PerformanceParms = *perfParms;

	const ovrHeadModelParms headModelParms = vrapi_DefaultHeadModelParms();
	// Calculate the view matrix.
	const ovrMatrix4f centerEyeViewMatrix = vrapi_GetCenterEyeViewMatrix( &headModelParms, &updatedTracking, NULL );

	ovrMatrix4f eyeViewMatrix[2];
	eyeViewMatrix[0] = vrapi_GetEyeViewMatrix( &headModelParms, &centerEyeViewMatrix, 0 );
	eyeViewMatrix[1] = vrapi_GetEyeViewMatrix( &headModelParms, &centerEyeViewMatrix, 1 );

	// Render.
	ovrFramebuffer * frameBuffer = &renderer->FrameBuffer[renderer->NumBuffers == 1 ? 0 : eye];
	parms.Layers[0].Textures[eye].ColorTextureSwapChain = frameBuffer->ColorTextureSwapChain;//swap chain handler
	parms.Layers[0].Textures[eye].TextureSwapChainIndex = frameBuffer->TextureSwapChainIndex;//swap chain index
	parms.Layers[0].Textures[eye].TexCoordsFromTanAngles = renderer->TexCoordsTanAnglesMatrix;
	parms.Layers[0].Textures[eye].HeadPose = updatedTracking.HeadPose;
	parms.Layers[0].Flags |= VRAPI_FRAME_LAYER_FLAG_CHROMATIC_ABERRATION_CORRECTION;

	//create fence
	ovrFence * fence = &renderer->Fence[eye][frameBuffer->TextureSwapChainIndex];
	ovrFence_Insert( fence );
	completionFence[eye] = (size_t)fence->Sync;	
	parms.Layers[0].Textures[eye].CompletionFence =
		completionFence[renderer->NumBuffers == 1 ? 0 : eye];

	// Hand over the eye images to the time warp.
	vrapi_SubmitFrame( renderThread->Ovr, &parms );		
```

