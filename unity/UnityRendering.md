# 渲染流程
```
Camera.Render
  Drawing
    Render.OpaqueGeometry
    Render.MotionVectors
    Camera.ImageEffects
    Render.TransparentGeometry
  Camera.ImageEffects
GUI.Repaint
PlayerEndofFrame
```
* 上述流程可以在gapid中追踪unity渲染过程得到
* 也可以在profile中查看
* 在android打包时，选择debug script则会在logcat中看到stacktrace
* 在脚本开始时设置`Application.SetStackTraceLogType(LogType.Log, StackTraceLogType.Full);`，可以在editor中查看调用栈

# single pass rendering
*  player setting打开vr支持 Virtual Reality Supported checkbox is ticked, then tick the Single-Pass Stereo Rendering 
*  SDK选择split display
*  rendertexture设置为空
*  在cameraCallback中设置commandBuffer，在开始渲染之前，通过CommandBuffer.IssuePluginEvent将Framebuffer改为包含Texture2DArray的FBO
*  通过shader.EnableKeyword设置multi-view相关的开关，以及muti-view所需要的matrix pair
*  渲染后期，将Texture2DArray纹理传给下层vrsdk进行后处理
*  一帧结束，通知vrsdk进行合成，并解除FBO绑定
*  skybox使用的view-project matrix不同于camera的，要分开设置
*  双眼视差设置后，抖动现象基本没有，原因不明，待进一步分析。

# single pass 流程

初始化single pass，创建RenderTexture做为framebuffer，同时底层创建texture array纹理
```
            var rt = new StereoScreen(width, height);
            if (SinglePassManager.isSupported)
            {
                SinglePassManager.SinglePassInit(this);
                SinglePassManager.AddCameraCommanBuffer(Camera.main);

                //InitDevice();
                UpdateState();
                //StereoScreen = device.CreateStereoScreen();

#if UNITY_ANDROID && !UNITY_EDITOR
                Camera.main.targetTexture = rt.GetRenderTexture(0);
                Camera.main.forceIntoRenderTexture = true;
#endif
                if (Camera.main.targetTexture)
                    SinglePassManager.SetFramebufferProfile(Camera.main.targetTexture.width, Camera.main.targetTexture.height,
                        Camera.main.targetTexture.antiAliasing);
                SinglePassManager.CreateTexture();
            }

```
打开shader关键字，获取single pass相关的变量和矩阵，手动配置
```
    internal static void SinglePassInit(BaseVRDevice device)
    {
        mDevices = device;
        if (!isSupported)
        {
           
        }
        //Debug.Log("~~~~SinglePassInit~~~~");
        Shader.EnableKeyword("STEREO_MULTIVIEW_ON");
        Shader.EnableKeyword("UNITY_SINGLE_PASS_STEREO");

        unity_StereoCameraProjection = MultipleMatrix("unity_CameraProjection", "unity_StereoCameraProjection");
        unity_StereoCameraInvProjection = MultipleMatrix("unity_CameraInvProjection", "unity_StereoCameraInvProjection");
        unity_StereoMatrixP = MultipleMatrix("glstate_matrix_projection", "unity_StereoMatrixP");

        unity_StereoScaleOffset[0] = new Vector4(1.0f, 1.0f, 0f, 0f);
        unity_StereoScaleOffset[1] = new Vector4(1.0f, 1.0f, 0.5f, 0f);
        Shader.SetGlobalVectorArray("unity_StereoScaleOffset", unity_StereoScaleOffset);

        Matrix4x4 proj = mDevices.GetProjection(GvrViewerInternal.Eye.Left);
        //realProj = GvrViewer.Instance.Projection(eye, GvrViewer.Distortion.Undistorted);

        //CopyCameraAndMakeSideBySide(controller, proj[0, 2], proj[1, 2]);

        // Fix aspect ratio and near/far clipping planes.
        float nearClipPlane = Camera.main.nearClipPlane;
        float farClipPlane = Camera.main.farClipPlane;

        GvrCameraUtils.FixProjection(Camera.main.rect, nearClipPlane, farClipPlane, ref proj);
        //GvrCameraUtils.FixProjection(cam.rect, nearClipPlane, farClipPlane, ref realProj);

        // Zoom the stereo cameras if requested.
        float monoProj11 = Camera.main.projectionMatrix[1, 1];
        GvrCameraUtils.ZoomStereoCameras(0, 0,
                                         monoProj11, ref proj);

        Camera.main.projectionMatrix = proj;
    }
```
配置camera commond buffer，在plugin中扩展原有的rendering pipe line
```
    internal static void AddCameraCommanBuffer(Camera mainCam)
    {
        mainCam.RemoveAllCommandBuffers();
        camera = mainCam;
        CommandBuffer cb = new CommandBuffer();

        cb.IssuePluginEvent(GetRenderEventFunc(), (int)CameraEvent.BeforeForwardOpaque);
        //cb.IssuePluginEvent(GetRenderEventFunc(), (int)CameraEvent.AfterEverything);

        mainCam.AddCommandBuffer(CameraEvent.BeforeForwardOpaque, cb);

        mAfterSkyCB = new CommandBuffer();
        mainCam.RemoveCommandBuffers(CameraEvent.AfterSkybox);
        mainCam.AddCommandBuffer(CameraEvent.AfterSkybox, mAfterSkyCB);

        mBeforeSkyCB = new CommandBuffer();
        mainCam.RemoveCommandBuffers(CameraEvent.BeforeSkybox);
        mainCam.AddCommandBuffer(CameraEvent.BeforeSkybox, mBeforeSkyCB);
    }
```
在pre-render时更新需要的矩阵
```
        public override void PreRender(StereoScreen stereoScreen)
        {
            if (SinglePassManager.isSupported)
                SinglePassManager.UpdateStereoMateix();
        }
```
更新single pass rendering所需要的矩阵    
Skybox需要单独设置unity_StereoMatrixVP
```
    internal static void UpdateStereoMateix()
    {
        //unity_StereoCameraProjection = MultipleMatrix("unity_CameraProjection", "unity_StereoCameraProjection");
        //unity_StereoCameraInvProjection = MultipleMatrix("unity_CameraInvProjection", "unity_StereoCameraInvProjection");
        //unity_StereoMatrixP = MultipleMatrix("glstate_matrix_projection", "unity_StereoMatrixP");

        unity_StereoCameraProjection[0] = GetEyeProjection(GvrViewerInternal.Eye.Left);
        unity_StereoCameraProjection[1] = GetEyeProjection(GvrViewerInternal.Eye.Right);

        unity_StereoCameraInvProjection[0] = unity_StereoCameraProjection[0].inverse;
        unity_StereoCameraInvProjection[1] = unity_StereoCameraProjection[1].inverse;

        float eyeOffset = GvrProfile.Default.viewer.lenses.separation * 0.5f;

        Matrix4x4 world2Camera = camera.worldToCameraMatrix;
        Matrix4x4 camera2World = camera.cameraToWorldMatrix;
        Matrix4x4 c2w_L, c2w_R, w2c_L, w2c_R;
        Vector3 eyeOffsetVector = new Vector3(eyeOffset, 0, 0);
        Matrix4x4 eyeOffsetMat = Matrix4x4.TRS(eyeOffsetVector, Quaternion.identity, Vector3.one);
        w2c_L = eyeOffsetMat * world2Camera;
        w2c_R = eyeOffsetMat.inverse * world2Camera;
        //w2c_L = world2Camera * eyeOffsetMat;
        //w2c_R = world2Camera * eyeOffsetMat.inverse;

        unity_StereoWorldToCamera[0] = w2c_L;
        unity_StereoWorldToCamera[1] = w2c_R;
        Shader.SetGlobalMatrixArray("unity_StereoWorldToCamera", unity_StereoWorldToCamera);

        c2w_L = camera2World * eyeOffsetMat;
        c2w_R = camera2World * eyeOffsetMat.inverse;
        unity_StereoCameraToWorld[0] = c2w_L;
        unity_StereoCameraToWorld[1] = c2w_R;
        Shader.SetGlobalMatrixArray("unity_StereoCameraToWorld", unity_StereoCameraToWorld);

        Vector4[] result = new Vector4[2];
        result[0] = camera.transform.position - camera.transform.right * eyeOffset;
        result[1] = camera.transform.position + camera.transform.right * eyeOffset;
        //result[1] = mainCam.transform.position + eyeOffsetVector;
        //result[0] = mainCam.transform.position - eyeOffsetVector;
        Shader.SetGlobalVectorArray("unity_StereoWorldSpaceCameraPos", result);

        Shader.SetGlobalMatrixArray("unity_StereoMatrixV", unity_StereoWorldToCamera);
        unity_StereoMatrixInvV[0] = w2c_L.inverse;
        unity_StereoMatrixInvV[1] = w2c_R.inverse;
        Shader.SetGlobalMatrixArray("unity_StereoMatrixInvV", unity_StereoMatrixInvV);


        //Matrix4x4 gpuProj = unity_StereoMatrixP[0];
        //unity_StereoMatrixVP[0] = gpuProj * w2c_L;
        //unity_StereoMatrixVP[1] = gpuProj * w2c_R;
        unity_StereoMatrixVP[0] = unity_StereoCameraProjection[0] * w2c_L;
        unity_StereoMatrixVP[1] = unity_StereoCameraProjection[1] * w2c_R;
        Shader.SetGlobalMatrixArray("unity_StereoMatrixVP", unity_StereoMatrixVP);

        //mainCam.SetStereoProjectionMatrix(Camera.StereoscopicEye.Left, mainCam.projectionMatrix);
        //mainCam.SetStereoProjectionMatrix(Camera.StereoscopicEye.Right, mainCam.projectionMatrix);
        //mainCam.SetStereoViewMatrix(Camera.StereoscopicEye.Left, unity_StereoWorldToCamera[0]);
        //mainCam.SetStereoViewMatrix(Camera.StereoscopicEye.Right, unity_StereoWorldToCamera[1]);

        //mAfterSkyCB = new CommandBuffer();
        mAfterSkyCB.Clear();
        //mainCam.RemoveCommandBuffers(CameraEvent.AfterSkybox);
        mAfterSkyCB.SetGlobalMatrixArray("unity_StereoMatrixVP", unity_StereoMatrixVP);
        //mainCam.AddCommandBuffer(CameraEvent.AfterSkybox, mAfterSkyCB);


        Matrix4x4 viewMatrix1 = Matrix4x4.LookAt(Vector3.zero, camera.transform.forward, camera.transform.up) * Matrix4x4.Scale(new Vector3(1, 1, -1));
        viewMatrix1 = viewMatrix1.transpose;
        //Matrix4x4 proj = Matrix4x4.Perspective(camera.fieldOfView, camera.aspect, camera.nearClipPlane, camera.farClipPlane);
        //Matrix4x4 proj = camera.projectionMatrix;
        Matrix4x4 projLeft = unity_StereoCameraProjection[0];
        projLeft.m22 = -1.0f;
        Matrix4x4 projRight = unity_StereoCameraProjection[1];
        projRight.m22 = -1.0f;
        //Matrix4x4 gpuP = GL.GetGPUProjectionMatrix(proj, true);
        Matrix4x4[] skybox_MatrixVP = new Matrix4x4[2];
        skybox_MatrixVP[0] = projLeft * viewMatrix1;
        skybox_MatrixVP[1] = projRight * viewMatrix1;


        if (!mFirsSetSkyCB)
        {
            //mBeforeSkyCB = new CommandBuffer();
            mBeforeSkyCB.Clear();
            //mainCam.RemoveCommandBuffers(CameraEvent.BeforeSkybox);
            mBeforeSkyCB.SetGlobalMatrixArray("unity_StereoMatrixVP", skybox_MatrixVP);
            //mainCam.AddCommandBuffer(CameraEvent.BeforeSkybox, mBeforeSkyCB);
        }


        mFirsSetSkyCB = false;


    }
```
# Multiview shader
## unity hlsl 对multiview的支持
```
//////////////////////////////////////////////////////
Keywords set in this variant: STEREO_MULTIVIEW_ON 
-- Vertex shader for "gles3":
Shader Disassembly:
#ifdef VERTEX
#version 300 es
#extension GL_OVR_multiview2 : require

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 _MainTex_ST;
layout(std140) uniform UnityStereoGlobals {
	vec4 hlslcc_mtx4x4unity_StereoMatrixP[8];
	vec4 hlslcc_mtx4x4unity_StereoMatrixV[8];
	vec4 hlslcc_mtx4x4unity_StereoMatrixInvV[8];
	vec4 hlslcc_mtx4x4unity_StereoMatrixVP[8];
	vec4 hlslcc_mtx4x4unity_StereoCameraProjection[8];
	vec4 hlslcc_mtx4x4unity_StereoCameraInvProjection[8];
	vec4 hlslcc_mtx4x4unity_StereoWorldToCamera[8];
	vec4 hlslcc_mtx4x4unity_StereoCameraToWorld[8];
	vec3 unity_StereoWorldSpaceCameraPos[2];
	vec4 unity_StereoScaleOffset[2];
};
layout(std140) uniform UnityStereoEyeIndices {
	vec4 unity_StereoEyeIndices[2];
};
layout(num_views = 2) in;
in highp vec4 in_POSITION0;
in highp vec2 in_TEXCOORD0;
out highp vec2 vs_TEXCOORD0;
out highp float vs_BLENDWEIGHT0;
vec4 u_xlat0;
uint u_xlatu0;
int u_xlati1;
vec4 u_xlat2;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat0 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    u_xlati1 = int(gl_ViewID_OVR) << 2;
    u_xlat2 = u_xlat0.yyyy * hlslcc_mtx4x4unity_StereoMatrixVP[(u_xlati1 + 1)];
    u_xlat2 = hlslcc_mtx4x4unity_StereoMatrixVP[u_xlati1] * u_xlat0.xxxx + u_xlat2;
    u_xlat2 = hlslcc_mtx4x4unity_StereoMatrixVP[(u_xlati1 + 2)] * u_xlat0.zzzz + u_xlat2;
    gl_Position = hlslcc_mtx4x4unity_StereoMatrixVP[(u_xlati1 + 3)] * u_xlat0.wwww + u_xlat2;
    u_xlatu0 = gl_ViewID_OVR;
    vs_BLENDWEIGHT0 = unity_StereoEyeIndices[int(u_xlatu0)].x;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
    return;
}

#endif
#ifdef FRAGMENT
#version 300 es

precision highp int;
uniform lowp sampler2D _MainTex;
in highp vec2 vs_TEXCOORD0;
layout(location = 0) out mediump vec4 SV_Target0;
lowp vec3 u_xlat10_0;
void main()
{
    u_xlat10_0.xyz = texture(_MainTex, vs_TEXCOORD0.xy).xyz;
    SV_Target0.xyz = u_xlat10_0.xyz;
    SV_Target0.w = 1.0;
    return;
}

#endif
```
## 普通场景vertex shader
```
#version 300 es
#extension GL_OVR_multiview2 : require

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 _MainTex_ST;
layout(std140) uniform UnityStereoGlobals {
	vec4 hlslcc_mtx4x4unity_StereoMatrixP[8];
	vec4 hlslcc_mtx4x4unity_StereoMatrixV[8];
	vec4 hlslcc_mtx4x4unity_StereoMatrixInvV[8];
	vec4 hlslcc_mtx4x4unity_StereoMatrixVP[8];
	vec4 hlslcc_mtx4x4unity_StereoCameraProjection[8];
	vec4 hlslcc_mtx4x4unity_StereoCameraInvProjection[8];
	vec4 hlslcc_mtx4x4unity_StereoWorldToCamera[8];
	vec4 hlslcc_mtx4x4unity_StereoCameraToWorld[8];
	vec3 unity_StereoWorldSpaceCameraPos[2];
	vec4 unity_StereoScaleOffset[2];
};
layout(num_views = 2) in;
in highp vec4 in_POSITION0;
in highp vec2 in_TEXCOORD0;
out mediump vec2 vs_TEXCOORD0;
vec4 u_xlat0;
int u_xlati1;
vec4 u_xlat2;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat0 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    u_xlati1 = int(gl_ViewID_OVR) << 2;
    u_xlat2 = u_xlat0.yyyy * hlslcc_mtx4x4unity_StereoMatrixVP[(u_xlati1 + 1)];
    u_xlat2 = hlslcc_mtx4x4unity_StereoMatrixVP[u_xlati1] * u_xlat0.xxxx + u_xlat2;
    u_xlat2 = hlslcc_mtx4x4unity_StereoMatrixVP[(u_xlati1 + 2)] * u_xlat0.zzzz + u_xlat2;
    gl_Position = hlslcc_mtx4x4unity_StereoMatrixVP[(u_xlati1 + 3)] * u_xlat0.wwww + u_xlat2;
    u_xlat0.xy = in_TEXCOORD0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
    vs_TEXCOORD0.xy = u_xlat0.xy;
    return;
}
```
## 普通场景fragment shader
```
#version 300 es

precision highp float;
precision highp int;
uniform lowp sampler2D _MainTex;
in mediump vec2 vs_TEXCOORD0;
layout(location = 0) out mediump vec4 SV_Target0;
lowp vec4 u_xlat10_0;
bool u_xlatb0;
mediump float u_xlat16_1;
void main()
{
    u_xlat10_0 = texture(_MainTex, vs_TEXCOORD0.xy);
    u_xlat16_1 = u_xlat10_0.w + -0.5;
    SV_Target0 = u_xlat10_0;
#ifdef UNITY_ADRENO_ES3
    u_xlatb0 = !!(u_xlat16_1<0.0);
#else
    u_xlatb0 = u_xlat16_1<0.0;
#endif
    if((int(u_xlatb0) * int(0xffffffffu))!=0){discard;}
    return;
}
```
## 视频播放vertex shader
```
#version 300 es
#extension GL_OVR_multiview2 : require
#extension GL_OES_EGL_image_external : require
#extension GL_OES_EGL_image_external_essl3 : enable
#define UNITY_NO_DXT5nm 1
#define UNITY_NO_RGBM 1
#define UNITY_ENABLE_REFLECTION_BUFFERS 1
#define UNITY_FRAMEBUFFER_FETCH_AVAILABLE 1
#define UNITY_NO_CUBEMAP_ARRAY 1
#define UNITY_NO_SCREENSPACE_SHADOWS 1
#define UNITY_PBS_USE_BRDF2 1
#define SHADER_API_MOBILE 1
#define UNITY_HARDWARE_TIER2 1
#define UNITY_COLORSPACE_GAMMA 1
#define UNITY_LIGHTMAP_DLDR_ENCODING 1
#define STEREO_MULTIVIEW_ON 1
#define FLIP_X 1
#define DEBUG_OFF 1
#ifndef SHADER_TARGET
    #define SHADER_TARGET 35
#endif
#ifndef SHADER_API_GLES3
    #define SHADER_API_GLES3 1
#endif
#line 1
#ifndef GLSL_SUPPORT_INCLUDED
#define GLSL_SUPPORT_INCLUDED

// Automatically included in raw GLSL (GLSLPROGRAM) shader snippets, to map from some of the legacy OpenGL
// variable names to uniform names used by Unity.

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif

uniform mat4 unity_ObjectToWorld;
uniform mat4 unity_WorldToObject;
uniform mat4 unity_MatrixVP;
uniform mat4 unity_MatrixV;
uniform mat4 unity_MatrixInvV;
uniform mat4 glstate_matrix_projection;

#define gl_ModelViewProjectionMatrix        (unity_MatrixVP * unity_ObjectToWorld)
#define gl_ModelViewMatrix                  (unity_MatrixV * unity_ObjectToWorld)
#define gl_ModelViewMatrixTranspose         (transpose(unity_MatrixV * unity_ObjectToWorld))
#define gl_ModelViewMatrixInverseTranspose  (transpose(unity_WorldToObject * unity_MatrixInvV))
#define gl_NormalMatrix                     (transpose(mat3(unity_WorldToObject * unity_MatrixInvV)))
#define gl_ProjectionMatrix                 glstate_matrix_projection

#if __VERSION__ < 120
mat3 transpose(mat3 mtx)
{
    vec3 c0 = mtx[0];
    vec3 c1 = mtx[1];
    vec3 c2 = mtx[2];

    return mat3(
        vec3(c0.x, c1.x, c2.x),
        vec3(c0.y, c1.y, c2.y),
        vec3(c0.z, c1.z, c2.z)
    );
}
mat4 transpose(mat4 mtx)
{
    vec4 c0 = mtx[0];
    vec4 c1 = mtx[1];
    vec4 c2 = mtx[2];
    vec4 c3 = mtx[3];

    return mat4(
        vec4(c0.x, c1.x, c2.x, c3.x),
        vec4(c0.y, c1.y, c2.y, c3.y),
        vec4(c0.z, c1.z, c2.z, c3.z),
        vec4(c0.w, c1.w, c2.w, c3.w)
    );
}
#endif // __VERSION__ < 120

#endif // GLSL_SUPPORT_INCLUDED

#line 24

#line 35
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif

#line 35
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif
/* UNITY: Original start of shader */

// #pragma only_renderers gles gles3
		
		
		

// #pragma multi_compile DEBUG_OFF DEBUG
// #pragma multi_compile ___ _STEREOMODE_TOPBOTTOM _STEREOMODE_LEFTRIGHT
// #pragma multi_compile ___ FLIP_X

		precision mediump int;
	precision mediump float;

 // VERTEX

 // FRAGMENT
	
// default float precision for fragment shader is patched on runtime as some drivers have issues with highp


#define gl_MultiTexCoord0 _glesMultiTexCoord0
in vec4 _glesMultiTexCoord0;


 uniform float _StereoMode;
 uniform mat4 video_matrix;
 uniform  vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
 uniform  vec4 _MainTex_ST;
 layout(std140) uniform UnityStereoGlobals{
  vec4 hlslcc_mtx4x4unity_StereoMatrixP[8];
 vec4 hlslcc_mtx4x4unity_StereoMatrixV[8];
 vec4 hlslcc_mtx4x4unity_StereoMatrixInvV[8];
 vec4 hlslcc_mtx4x4unity_StereoMatrixVP[8];
 vec4 hlslcc_mtx4x4unity_StereoCameraProjection[8];
 vec4 hlslcc_mtx4x4unity_StereoCameraInvProjection[8];
 vec4 hlslcc_mtx4x4unity_StereoWorldToCamera[8];
 vec4 hlslcc_mtx4x4unity_StereoCameraToWorld[8];
 vec3 unity_StereoWorldSpaceCameraPos[2];
 vec4 unity_StereoScaleOffset[2];
 };
 layout(num_views = 2) in;
 in highp vec4 in_POSITION0;
 in highp vec2 in_TEXCOORD0;
 out highp vec2 vs_TEXCOORD0;
 out highp vec4 debug_Color;
 vec4 u_xlat0;
 int u_xlati1;
 vec4 u_xlat2;
 //out vec2 uv;
 void main()
 {
  //vs_TEXCOORD0.xy = in_TEXCOORD0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
  u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
  u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
  u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
  u_xlat0 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
  u_xlati1 = int(gl_ViewID_OVR) << 2;
  u_xlat2 = u_xlat0.yyyy * hlslcc_mtx4x4unity_StereoMatrixVP[(u_xlati1 + 1)];
  u_xlat2 = hlslcc_mtx4x4unity_StereoMatrixVP[u_xlati1] * u_xlat0.xxxx + u_xlat2;
  u_xlat2 = hlslcc_mtx4x4unity_StereoMatrixVP[(u_xlati1 + 2)] * u_xlat0.zzzz + u_xlat2;
  gl_Position = hlslcc_mtx4x4unity_StereoMatrixVP[(u_xlati1 + 3)] * u_xlat0.wwww + u_xlat2;

  vec4 untransformedUV = gl_MultiTexCoord0;
#ifdef FLIP_X
  untransformedUV.x = 1.0 - untransformedUV.x;
#endif  // FLIP_X
  //if ((int)_StereoMode == 1)
  //{
  // untransformedUV.y *= 0.5;
  // if ((int)gl_ViewID_OVR == 0) {
  //  untransformedUV.y += 0.5;
  // }
  //}
  //else if ((int)_StereoMode == 2)
  //{
  // untransformedUV.x *= 0.5;
  // if ((int)gl_ViewID_OVR != 0) {
  //  untransformedUV.x += 0.5;
  // }
  //}
#ifdef DEBUG
  if (u_xlati1 == 0) {
   debug_Color = vec4(1, 0, 0, 1);
  }
  else
  {
   debug_Color = vec4(0, 1, 0, 1);
  }

#endif
#ifdef _STEREOMODE_TOPBOTTOM
  untransformedUV.y *= 0.5;
  if (u_xlati1 == 0) {
   untransformedUV.y += 0.5;
  }
#endif  // _STEREOMODE_TOPBOTTOM
#ifdef _STEREOMODE_LEFTRIGHT
  untransformedUV.x *= 0.5;
  if (u_xlati1 != 0) {
   untransformedUV.x += 0.5;
  }
#endif  // _STEREOMODE_LEFTRIGHT
  vs_TEXCOORD0 = (video_matrix * untransformedUV).xy;
  return;
 }

```
## 视频播放fragment shader
```
#version 300 es
#extension GL_OVR_multiview2 : require
#extension GL_OES_EGL_image_external : require
#extension GL_OES_EGL_image_external_essl3 : enable
#define UNITY_NO_DXT5nm 1
#define UNITY_NO_RGBM 1
#define UNITY_ENABLE_REFLECTION_BUFFERS 1
#define UNITY_FRAMEBUFFER_FETCH_AVAILABLE 1
#define UNITY_NO_CUBEMAP_ARRAY 1
#define UNITY_NO_SCREENSPACE_SHADOWS 1
#define UNITY_PBS_USE_BRDF2 1
#define SHADER_API_MOBILE 1
#define UNITY_HARDWARE_TIER2 1
#define UNITY_COLORSPACE_GAMMA 1
#define UNITY_LIGHTMAP_DLDR_ENCODING 1
#define STEREO_MULTIVIEW_ON 1
#define FLIP_X 1
#define DEBUG_OFF 1
#ifndef SHADER_TARGET
    #define SHADER_TARGET 35
#endif
#ifndef SHADER_API_GLES3
    #define SHADER_API_GLES3 1
#endif
#line 1
#ifndef GLSL_SUPPORT_INCLUDED
#define GLSL_SUPPORT_INCLUDED

// Automatically included in raw GLSL (GLSLPROGRAM) shader snippets, to map from some of the legacy OpenGL
// variable names to uniform names used by Unity.

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif

uniform mat4 unity_ObjectToWorld;
uniform mat4 unity_WorldToObject;
uniform mat4 unity_MatrixVP;
uniform mat4 unity_MatrixV;
uniform mat4 unity_MatrixInvV;
uniform mat4 glstate_matrix_projection;

#define gl_ModelViewProjectionMatrix        (unity_MatrixVP * unity_ObjectToWorld)
#define gl_ModelViewMatrix                  (unity_MatrixV * unity_ObjectToWorld)
#define gl_ModelViewMatrixTranspose         (transpose(unity_MatrixV * unity_ObjectToWorld))
#define gl_ModelViewMatrixInverseTranspose  (transpose(unity_WorldToObject * unity_MatrixInvV))
#define gl_NormalMatrix                     (transpose(mat3(unity_WorldToObject * unity_MatrixInvV)))
#define gl_ProjectionMatrix                 glstate_matrix_projection

#if __VERSION__ < 120
mat3 transpose(mat3 mtx)
{
    vec3 c0 = mtx[0];
    vec3 c1 = mtx[1];
    vec3 c2 = mtx[2];

    return mat3(
        vec3(c0.x, c1.x, c2.x),
        vec3(c0.y, c1.y, c2.y),
        vec3(c0.z, c1.z, c2.z)
    );
}
mat4 transpose(mat4 mtx)
{
    vec4 c0 = mtx[0];
    vec4 c1 = mtx[1];
    vec4 c2 = mtx[2];
    vec4 c3 = mtx[3];

    return mat4(
        vec4(c0.x, c1.x, c2.x, c3.x),
        vec4(c0.y, c1.y, c2.y, c3.y),
        vec4(c0.z, c1.z, c2.z, c3.z),
        vec4(c0.w, c1.w, c2.w, c3.w)
    );
}
#endif // __VERSION__ < 120

#endif // GLSL_SUPPORT_INCLUDED

#line 24

#line 35
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif

#line 35
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif
/* UNITY: Original start of shader */

// #pragma only_renderers gles gles3
		
		
		

// #pragma multi_compile DEBUG_OFF DEBUG
// #pragma multi_compile ___ _STEREOMODE_TOPBOTTOM _STEREOMODE_LEFTRIGHT
// #pragma multi_compile ___ FLIP_X

		precision mediump int;
	precision mediump float;

 // VERTEX

 // FRAGMENT
	
// default float precision for fragment shader is patched on runtime as some drivers have issues with highp



	//version 300 es

		precision highp int;
	uniform lowp samplerExternalOES _MainTex;
	uniform float _Gamma;
	in highp vec2 vs_TEXCOORD0;
	in highp vec4 debug_Color;
	layout(location = 0) out mediump vec4 SV_Target0;
	lowp vec4 u_xlat10_0;
	vec3 gammaCorrect(vec3 v, float gamma) {
		return pow(v, vec3(1.0 / gamma));
	}

	// Apply the gamma correction.  One possible optimization that could
	// be applied is if _Gamma == 2.0, then use gammaCorrectApprox since sqrt will be faster.
	// Also, if _Gamma == 1.0, then there is no effect, so this call could be skipped all together.
	vec4 gammaCorrect(vec4 v, float gamma) {
		return vec4(gammaCorrect(v.xyz, gamma), v.w);
	}

	void main()
	{
		u_xlat10_0 = gammaCorrect(texture(_MainTex, vs_TEXCOORD0.xy), _Gamma);
		SV_Target0 = u_xlat10_0;
#ifdef DEBUG
		SV_Target0 = SV_Target0 * debug_Color;
#endif
		return;
	}

```