# introduce
TimeWarp provides intermediate frames based on very recent head pose information when your game starts to slow down. It works by distorting the previous frame to match the more recent head pose, and while it will help you smooth out a few dropped frames now and then, it’s not an excuse to run at less than 60 frames per second all the time. If you see black flickering bars at the edges of your vision when you shake your head, that indicates that your game is running slowly enough that TimeWarp doesn’t have a recent enough frame to fill in the blanks.

# Why warp?
Now we consider one of the keystones of this combination, the Timewarp process. Due to the comparatively gradual changes of scene in an immersive VR application, the image changes between views by a small and therefore, relatively predictable amount. Warping is basically shifting an image rendered at an older head location to match a newer one. This partially decouples the application frame rate from the refresh rate and allows the system to enforce a latency guarantee that some applications may not provide. This shifting can account for changes in head rotation but not head position or scene animation. It’s therefore something of an approximation but provides an effective safety net and also enables an application running at 30 FPS to appear (at least in part) as if it’s tracking the users head at 60 FPS or above.[ref](https://community.arm.com/groups/arm-mali-graphics/blog/2016/03/01/virtual-reality-blatant-latency-and-how-to-avoid-it)

# Timewarp
"Time Warp: Any pixel on the screen, along with the associated depth buffer value, can be converted back to a world space position, which can be re-transformed to a different screen space pixel location for a modified set of view parameters."
its just adjusting the angle not position
You need the depth buffer to adjust either. The reason translation is ignored and only angle is adjusted is to avoid the occlusion problem.
# Depth info
Dept information could be embedded into the rbg pixel data send to the device. Lets say 24bit pixel uses 6 bit dept information (using lowest 2 bits per color r,b,g). Maybe hdmi has some alpha channel or higher bit/pixel settings, don't know. Also there are unused area's of the screen that can be used for sending depth information.
If that all isn't possible, you could even get depth info out of the stereo image itselve. And even for a single image you can get dept info like in ptam/dtam or Hyperlapse
So I think it is still possible.

# algorithm impl
## Distortion generate ray trace directions. 

So the input of distortion is a pixel coordinate - the physical pixel on the display itself.  The output is the real-world direction of the ray from this pixel as it comes out of the lens and hits the eye.
 However we typically think of rays "coming from" the eye, so the direction (TanAngleX,TanAngleY,1) is the direction
 that the pixel appears to be in real-world space, where AngleX and AngleY are relative to the straight-ahead vector. 

For a pixel location, calculate the meters to the center point
		Scale that by LensMetersPerTanDegreeAtCenter then apply distortion
		to get an actual tanAngle.
		Scale the tanAngle to get the FBO texture coordinate.
```
	float theta[2];
	for ( int i = 0; i < 2; i++ ) {
		const float unit = in[i];
		const float ndc = 2.0f * ( unit - 0.5f );
		const float pixels = ndc * hmdInfo.heightPixels * 0.5f;
		const float meters = pixels * hmdInfo.widthMeters / hmdInfo.widthPixels;
		const float tanAngle = meters / hmdInfo.lens.MetersPerTanAngleAtCenter;
		theta[i] = tanAngle;
	}
```
MetersPerTanAngleAtCenter is the relationship between distance on 
a screen (at the center of the lens)(镜头中心到屏幕的距离), and the angle variance of the light after it
 has passed through the lens.    
MetersPerTanAngleAtCenter is also known as focal length!
```
MetersPerTanAngleAtCenter = MetersOnScreenAtCenter/tanHalfFov
MetersPerTanAngleAtCenter  = 0.033/tan(42.5/180*3.1415926)
```

## Generate TexCoordsFromTanAngles for tangent sapce to texture space

Points on the screen are mapped by a distortion correction
function into ( TanX, TanY, 1, 1 ) vectors that are transformed
by this matrix to get ( S, T, Q, _ ) vectors that are looked
up with texture2dproj() to get texels.
```
TanX = x_meters / hmdInfo.lens.MetersPerTanAngleAtCenter=x_meters*tanHalfFov/ MetersOnScreenAtCenter
textureNdcX = distortion_scale * TanX
( S, T, Q, _ ) = (0.5f*textureNdcX/tanHalfFov-0.5, 0.5f*textureNdcY/tanHalfFov-0.5, -1.0f, -1.0f)
S=0.5f * distortion_scale * x_meters/ MetersOnScreenAtCenter+0.5
T=0.5f * distortion_scale * y_meters/ MetersOnScreenAtCenter+0.5
```

```
inline ovrMatrix4f TanAngleMatrixFromFov( const float fovDegrees )
{
	const float tanHalfFov = tanf( 0.5f * fovDegrees * ( M_PI / 180.0f ) );
	const ovrMatrix4f tanAngleMatrix =
	{ {
		{ 0.5f / tanHalfFov, 0.0f, -0.5f, 0.0f },
		{ 0.0f, 0.5f / tanHalfFov, -0.5f, 0.0f },
		{ 0.0f, 0.0f, -1.0f, 0.0f },
		{ 0.0f, 0.0f, -1.0f, 0.0f }
	} };
	return tanAngleMatrix;
}
```
## create texture transform matrix from new orientation
`Texm = TexCoordsFromTanAngles * warp`

##  calculate texture point coord
`vec3 left = Texm * vec4(TexCoord,-1,1)`

## Transform texture point from 3D to 2D 
`oTexCoord = vec2( proj.x * projIZ, proj.y * projIZ )`

# vrlib shader
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

# [C# time warping code impl](http://pastebin.com/pTMSnaiW)
time warp 核心思想：
* 通过z-buffer和fov恢复图像原始坐标(x, y, z-depth)
* 将新变换应用于恢复后的坐标上
* 将变换后的坐标通过除以新的z坐标转换为新的2D图像坐标(x',y')
outline
```
double centerZ = depthMap[i];//origin image depths
PointF vertex = TransformImagePoint(rotateDegreesX, rotateDegreesY, zTranslate, xTranslate, x, y, centerZ, out newZ);
```
restore orignal coord 
```
double centerZ = depthMap[i]
scalex = 2 * Math.Tan(fovDegreesHorizontal * Math.PI / 180 / 2) * zscale;
scaley = 2 * Math.Tan(fovDegreesVertical * Math.PI / 180 / 2) * zscale;
x = (x / scalex) * (imageWidth) + (imageWidth / 2);//image space to wordspace
y = (y / scaley) * (imageHeight) + (imageHeight / 2);
```
transform point with new rotate
```
private static PointF TransformImagePoint(double rotateDegreesX, double rotateDegreesY, double zTranslate, double xTranslate, double x, double y, double z, out double newZ)
{
	// z /= Math.Sqrt(1*1+Math.Sqrt(x*x+y*y));
	ImageSpaceToWorldSpace(x, y, out x, out y);
	TransformPoint(zTranslate, xTranslate, rotateDegreesX, rotateDegreesY, ref x, ref y, ref z);
	WorldSpaceToImageSpace(ref x, ref y);
	PointF transformedScreenPoint = new PointF((float)x, (float)y);
	newZ = z;
	return transformedScreenPoint;
}
```

```
private static void TransformPoint(double zTranslate, double xTranslate, double rotateDegreesX, double rotateDegreesY, ref double x, ref double y, ref double z)
{
	double sina, cosa;

	x *= z;
	y *= z;
	z += zTranslate;

	x -= xTranslate;

	if (rotateDegreesX != 0.0)
	{
		sina = Math.Sin(rotateDegreesX * Math.PI / 180);
		cosa = Math.Cos(rotateDegreesX * Math.PI / 180);
		double xnew = x * cosa - z * sina;
		double znew = x * sina + z * cosa;
		x = xnew; z = znew;
	}

	if (rotateDegreesY != 0.0)
	{
		sina = Math.Sin(rotateDegreesY * Math.PI / 180);
		cosa = Math.Cos(rotateDegreesY * Math.PI / 180);
		double ynew = y * cosa - z * sina;
		double znew = y * sina + z * cosa;
		y = ynew; z = znew;
	}

	z -= zTranslate;
	x /= z;
	y /= z;
}
```

# Overlay warp
```
		"uniform mediump mat4 Mvpm;\n"
		"uniform mediump mat4 Texm;\n"
		"uniform mediump mat4 Texm2;\n"
		"uniform mediump mat4 Texm3;\n"//overlay top orient
		"uniform mediump mat4 Texm4;\n"//overlay botton orient

		"attribute vec4 Position;\n"
		"attribute vec2 TexCoord;\n"
		"attribute vec2 TexCoord1;\n"
		"varying  vec2 oTexCoord;\n"
		"varying  vec3 oTexCoord2;\n"	// Must do the proj in fragment shader or you get wiggles when you view the plane at even modest angles.
		"void main()\n"
		"{\n"
		"   gl_Position = Mvpm * Position;\n"
		"	vec3 proj;\n"
		"	float projIZ;\n"
		""
		"   proj = mix( vec3( Texm * vec4(TexCoord,-1,1) ), vec3( Texm2 * vec4(TexCoord,-1,1) ), TexCoord1.x );\n"
		"	projIZ = 1.0 / max( proj.z, 0.00001 );\n"
		"	oTexCoord = vec2( proj.x * projIZ, proj.y * projIZ );\n"
		""
		"   oTexCoord2 = mix( vec3( Texm3 * vec4(TexCoord,-1,1) ), vec3( Texm4 * vec4(TexCoord,-1,1) ), TexCoord1.x );\n"
		""
		"}\n"
	,
		"uniform sampler2D Texture0;\n"
		"uniform sampler2D Texture1;\n"
		"varying highp vec2 oTexCoord;\n"
		"varying highp vec3 oTexCoord2;\n"
		"void main()\n"
		"{\n"
		"	lowp vec4 color0 = texture2D(Texture0, oTexCoord);\n"
		"	{\n"
		"		lowp vec4 color1 = vec4( texture2DProj(Texture1, oTexCoord2).xyz, 1.0 );\n"
		"		gl_FragColor = mix( color1, color0, color0.w );\n"	// pass through destination alpha
		"	}\n"
		"}\n"
```
# Camera warp
camera　增加滚动
```
		"uniform mediump mat4 Mvpm;\n"
		"uniform mediump mat4 Texm;\n"
		"uniform mediump mat4 Texm2;\n"
		"uniform mediump mat4 Texm3;\n"
   		"uniform mediump mat4 Texm4;\n"
   		"uniform mediump mat4 Texm5;\n"

		"attribute vec4 Position;\n"
		"attribute vec2 TexCoord;\n"
		"attribute vec2 TexCoord1;\n"
		"varying  vec2 oTexCoord;\n"
   		"varying  vec2 oTexCoord2;\n"
		"void main()\n"
		"{\n"
		"   gl_Position = Mvpm * Position;\n"

    	"   vec4 lens = vec4(TexCoord,-1.0,1.0);"
		"	vec3 proj;\n"
		"	float projIZ;\n"
		""
		"   proj = mix( vec3( Texm * lens ), vec3( Texm2 * lens ), TexCoord1.x );\n"
		"	projIZ = 1.0 / max( proj.z, 0.00001 );\n"
		"	oTexCoord = vec2( proj.x * projIZ, proj.y * projIZ );\n"
		""
   		"   vec4 dir = mix( lens, Texm2 * lens, TexCoord1.x );\n"
    		" dir.xy /= dir.z*-1.0;\n"
    		" dir.z = -1.0;\n"
    		" dir.w = 1.0;\n"
    	"	float rolling = Position.y * -1.5 + 0.5;\n"	// roughly 0 = top of camera, 1 = bottom of camera
   		"   proj = mix( vec3( Texm3 * lens ), vec3( Texm4 * lens ), rolling );\n"
   		"	projIZ = 1.0 / max( proj.z, 0.00001 );\n"
   		"	oTexCoord2 = vec2( proj.x * projIZ, proj.y * projIZ );\n"
		""
		"}\n"
	,
		"#extension GL_OES_EGL_image_external : require\n"
		"uniform sampler2D Texture0;\n"
		"uniform samplerExternalOES Texture1;\n"
		"varying highp vec2 oTexCoord;\n"
		"varying highp vec2 oTexCoord2;\n"
		"void main()\n"
		"{\n"
		"	lowp vec4 color0 = texture2D(Texture0, oTexCoord);\n"
		"		lowp vec4 color1 = vec4( texture2D(Texture1, oTexCoord2).xyz, 1.0 );\n"
		"		gl_FragColor = mix( color1, color0, color0.w );\n"	// pass through destination alpha
//		" gl_FragColor = color1;"
		"}\n"
```
# Discussion
* Timewarp+predict. Because the video is scanned out at a rate of about 120 scan lines a millisecond, scan lines farther to the right have a greater latency than lines to the left. On a sluggish LCD this doesn't really matter, but on a crisp switching OLED, users may feel like the world is subtly stretching or shearing when they turn quickly. This is corrected by predicting the head attitude at the beginning of each eye, a prediction of < 8 milliseconds, and the end of each eye, < 16 milliseconds. These predictions are used to calculate time warp transformations, and the warp is interpolated between these two values for each scan line drawn.
* TimeWarp Minimum Vsyncs. The TimeWarp MinimumVsyncs parameter default value is 1 for a 60 FPS target. Setting it to 2 will reduce the maximum application frame rate to no more than 30 FPS. The asynchronous TimeWarp thread will continue to render new frames with updated head tracking at 60 FPS, but the application will only have an opportunity to generate 30 new stereo pairs of eye buffers per second. You can set higher values for experimental purposes, but the only sane values for shipping apps are 1 and 2. 如果应用渲染帧率达不到60fps，可以考虑将MininumVsync设置为2，这样会强制应用帧率降至30fps，以节省渲染开销。
* FOV and Timewarp.  increasing the field of view used for the eye buffers gives it more cushion off the edges to pull from. For native applications, we currently add 10 degrees to the FOV when the frame rate is below 60. If the resolution of the eye buffers is not increased, this effectively lowers the resolution in the center of the screen.

# 
```
	m.M[0][0] = 0.5f * inv.M[2][0] - 0.5f * ( inv.M[0][0] * inv.M[2][3] - inv.M[0][3] * inv.M[2][0] );
	m.M[0][1] = 0.5f * inv.M[2][1] - 0.5f * ( inv.M[0][1] * inv.M[2][3] - inv.M[0][3] * inv.M[2][1] );
	m.M[0][2] = 0.5f * inv.M[2][2] - 0.5f * ( inv.M[0][2] * inv.M[2][3] - inv.M[0][3] * inv.M[2][2] );
	m.M[0][3] = 0.0f;
	m.M[1][0] = 0.5f * inv.M[2][0] + 0.5f * ( inv.M[1][0] * inv.M[2][3] - inv.M[1][3] * inv.M[2][0] );
	m.M[1][1] = 0.5f * inv.M[2][1] + 0.5f * ( inv.M[1][1] * inv.M[2][3] - inv.M[1][3] * inv.M[2][1] );
	m.M[1][2] = 0.5f * inv.M[2][2] + 0.5f * ( inv.M[1][2] * inv.M[2][3] - inv.M[1][3] * inv.M[2][2] );
	m.M[1][3] = 0.0f;
	m.M[2][0] = m.M[3][0] = inv.M[2][0];
	m.M[2][1] = m.M[3][1] = inv.M[2][1];
	m.M[2][2] = m.M[3][2] = inv.M[2][2];
	m.M[2][3] = m.M[3][3] = 0.0f;

	inv.M[2][0]		inv.M[2][1]		inv.M[2][2]		0.0f
	inv.M[2][0]		inv.M[2][1]		inv.M[2][2]		0.0f
	inv.M[2][0]		inv.M[2][1]		inv.M[2][2]		0.0f
	inv.M[2][0]		inv.M[2][1]		inv.M[2][2]		0.0f
```

# timewarp and distortion
畸变校正是在ATW过程中作用的。先是将点从NDC空间变换到屏幕空间，再变换到透镜空间，然后计算不同坐标对应的scale。
scale施加到坐标上生成distortion mash。ATW进行方向扭转，不会影响到mash的形状，只是改变了mash映射到纹理buffer的位置。
所以ATW不会对畸变校正产生影响。

# ref
[mobile timewarp overview](https://developer.oculus.com/documentation/mobilesdk/latest/concepts/mobile-timewarp-overview/)

[Post-Rendering 3D Warping](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.13.1789&rep=rep1&type=pdf)