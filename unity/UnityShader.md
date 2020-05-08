# Conventions
* SV_XXX system value
* XX_ST scale and transform

# Macros
## Tilling and Offset
```
//#define TRANSFORM_TEX(tex,name) (tex.xy * name##_ST.xy + name##_ST.zw)
i.uv = TRANSFORM_TEX(v.uv, _MainTex);//i.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
```

# SurfaceShader
Unity provides a framework to quickly generate shaders that perform default lighting calculations, 
which you can influence by adjusting certain values. Such shaders are known as surface shaders.

# KeywordEnum 
displays a popup menu for a float property, and enables corresponding shader keyword. This is used with "#pragma multi_compile" in shaders, to enable or disable parts of shader code. Each name will enable "property name" + underscore + "enum name", uppercased, shader keyword. Up to 9 names can be provided.
```
// Display a popup with None, Add, Multiply choices.
// Each option will set _OVERLAY_NONE, _OVERLAY_ADD, _OVERLAY_MULTIPLY shader keywords.
[KeywordEnum(None, Add, Multiply)] _Overlay ("Overlay mode", Float) = 0

// ...later on in CGPROGRAM code:
#pragma multi_compile _OVERLAY_NONE _OVERLAY_ADD _OVERLAY_MULTIPLY
// ...
```
[see doc](https://docs.unity3d.com/ScriptReference/MaterialPropertyDrawer.html)

It only needs a single keyword, VERTEXLIGHT_ON. The other option is simply no keyword at all. To indicate that, we have to use _.
```
#pragma multi_compile _ VERTEXLIGHT_ON
```

## Shader.EnableKeyword
使能shader中的宏定义

# UnityShaderVariables
## XXX_TexelSize
```
sampler2D _HeightMap;
float4 _HeightMap_TexelSize;
```
The smallest sensible difference would cover a single texel of our texture. 
We can retrieve this information in the shader via a float4 variable with the _TexelSize suffix. 
Unity sets those variables, similar to _ST variables.
## _WorldSpaceLightPos0
```
	float3 lightDir = _WorldSpaceLightPos0.xyz;
	return DotClamped(lightDir, i.normal);
```
## unity_ObjectToWorld  
Multiply this matrix with the normal in the vertex 
shader to transform it to world space. And because it's a direction, 
repositioning should be ignored. So the fourth homogeneous coordinate must be zero.

法向量要使用worldToObject矩阵的逆来变换到世界坐标，这样才能解决不同scale造成法向变形的问题。
```
	i.normal = mul(
		transpose((float3x3)unity_WorldToObject),
		v.normal
	);
	i.normal = normalize(i.normal);
```
或者unity有内置函数UnityObjectToWorldNormal可以直接用
```
	Interpolators MyVertexProgram (VertexData v) {
		Interpolators i;
		i.position = mul(UNITY_MATRIX_MVP, v.position);
		i.normal = UnityObjectToWorldNormal(v.normal);
		i.uv = TRANSFORM_TEX(v.uv, _MainTex);
		return i;
	}
```
[see](http://catlikecoding.com/unity/tutorials/rendering/part-4/)
## UnityObjectToWorldDir
```
// Transforms direction from world to object space
inline float3 UnityWorldToObjectDir (in float3 dir) {
	return normalize(mul((float3x3)unity_WorldToObject, dir));
}
```
## unity_WorldTransformParams 
镜像变换时
by defining the float4 unity_WorldTransformParams variable. 
Its fourth component contains −1 when we need to flip the binormal, and 1 otherwise.
```
	float binormal = cross(i.normal, i.tangent.xyz) *
	(i.tangent.w * unity_WorldTransformParams.w);
```
## _WorldSpaceCameraPos
计算视线方向
```
float3 normal : TEXCOORD1;
float3 worldPos : TEXCOORD2;

i.worldPos = mul(unity_ObjectToWorld, v.position);
float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
```
