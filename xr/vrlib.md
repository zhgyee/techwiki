# draw swq
```
AppLocal::VrThreadFunction()->JavaSample::Frame()->DrawEyeViewsPostDistorted()->DrawEyeView()
															|
															v
							TimeWarpLocal::WarpSwap<----ivr_WarpSwap
									|
									|------<sync>--->WarpToScreen()
									-------<async>-->wait warp thread
```
# event seq
```
VrActivity
	+->dispatchGenericMotionEvent->nativeTouch->queue "touch" msg-+
	+->dispatchKeyEvent->nativeKeyEvent->queue "key" msg----------v
				vrMessageQueue.GetNextMessage()----AppLocal::VrThreadFunction
				|+-->AppLocal::Command
								|
								V
				IdealseePlayer::OnKeyEvent
				IdealseePlayer::Frame(input)
```
# FOV动态调整
通过调整FOV来减缓ATW引起的黑边效应。
```
float CalcFovIncrease()
{
        // Increase the fov by about 10 degrees if we are not holding 60 fps so
        // there is less black pull-in at the edges.
        //
        // Doing this dynamically based just on time causes visible flickering at the
        // periphery when the fov is increased, so only do it if minimumVsyncs is set.
        float fovIncrease = ( up.allowFovIncrease &&
                                                                ( ( up.SwapParms.MinimumVsyncs > 1 ) || ovr_GetPowerLevelStateThrottled() ) ) ? 10.0f : 0.0f;

        // Increase the fov when not rendering the vignette to hide
        // edge artifacts
        fovIncrease += ( !up.showVignette ) ? 5.0f : 0.0f;

        return fovIncrease;
}

```
# screen coverage modify
```
// This is a product of the lens distortion and the screen size,
// but there is no truly correct answer.
//
// There is a tradeoff in resolution and coverage.
// Too small of an fov will leave unrendered pixels visible, but too
// large wastes resolution or fill rate.  It is unreasonable to
// increase it until the corners are completely covered, but we do
// want most of the outside edges completely covered.
//
// Applications might choose to render a larger fov when angular
// acceleration is high to reduce black pull in at the edges by
// TimeWarp.
		hmdInfo.lensSeparation = 0.058f/1.2f;//0.0625f;	// JDC: measured on 8/23/2014
		hmdInfo.eyeTextureFov[0] = 92.0f;
		hmdInfo.eyeTextureFov[1] = 92.0f;
```
## distortion parameters
```
hmdInfo.lens.K[0]                          = 1.0f;
hmdInfo.lens.K[1]                          = 1.0128;//1.029f;
hmdInfo.lens.K[2]                          = 1.0286;//1.0565f;
hmdInfo.lens.K[3]                          = 1.0475;//1.088f;
hmdInfo.lens.K[4]                          = 1.0697;//1.127f;
hmdInfo.lens.K[5]                          = 1.0956;//1.175f;
hmdInfo.lens.K[6]                          = 1.1258;//1.232f;
hmdInfo.lens.K[7]                          = 1.1610;//1.298f;
hmdInfo.lens.K[8]                          = 1.2024;//1.375f;
hmdInfo.lens.K[9]                          = 1.2515;//1.464f;
hmdInfo.lens.K[10]                         = 1.3107;//1.570f;
```
# warp shader
## vert shader
```
uniform mediump mat4 Mvpm;
uniform mediump mat4 Texm;
uniform mediump mat4 Texm2;

attribute vec4 Position;
attribute vec2 TexCoord;
attribute vec2 TexCoord1;
varying  vec2 oTexCoord;
void main()
{
   gl_Position = Mvpm * Position;
   vec3 left = vec3( Texm * vec4(TexCoord,-1,1) );
   vec3 right = vec3( Texm2 * vec4(TexCoord,-1,1) );
   vec3 proj = mix( left, right, TexCoord1.x );
	float projIZ = 1.0 / max( proj.z, 0.00001 );
	oTexCoord = vec2( proj.x * projIZ, proj.y * projIZ );
}
```
## fragment shader
```
uniform sampler2D Texture0;
varying highp vec2 oTexCoord;
void main()
{
	gl_FragColor = texture2D(Texture0, oTexCoord);
}
```
