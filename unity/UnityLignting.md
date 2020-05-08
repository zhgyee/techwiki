Every visible object always gets rendered with its base pass. This pass takes care of the main directional light. 
Every additional light will add an extra additive pass on top of that. 
Thus, many lights will result in many draw calls. 
Many lights with many objects in their range will result in a whole lot of draw calls.
# Pixel Light Count
To keep the amount of draw calls in check, you can limit the Pixel Light Count via the quality settings. 
This defines the maximum amount of pixels lights used per object. 
Lights are referred to as pixel lights, when they are computed per fragment.

Higher quality levels allow more pixel lights. The default of the highest quality level is four pixel lights.

# Diffuse Shading
```
	float4 MyFragmentProgram (Interpolators i) : SV_TARGET {
		i.normal = normalize(i.normal);
		float3 lightDir = _WorldSpaceLightPos0.xyz;
		float3 lightColor = _LightColor0.rgb;
		float3 diffuse = lightColor * DotClamped(lightDir, i.normal);
		return float4(diffuse, 1);
	}
```
# Albedo
The color of the diffuse reflectivity of a material is known as its albedo. Albedo is Latin for whiteness. 
So it describes how much of the red, green, and blue color channels are diffusely reflected. The rest is absorbed.
```
	float4 MyFragmentProgram (Interpolators i) : SV_TARGET {
		i.normal = normalize(i.normal);
		float3 lightDir = _WorldSpaceLightPos0.xyz;
		float3 lightColor = _LightColor0.rgb;
		float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
		float3 diffuse =
			albedo * lightColor * DotClamped(lightDir, i.normal);
		return float4(diffuse, 1);
	}
```
# Specular Shading
```
	Properties {
		_Tint ("Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Albedo", 2D) = "white" {}
		_SpecularTint ("Specular", Color) = (0.5, 0.5, 0.5)
		_Smoothness ("Smoothness", Range(0, 1)) = 0.1
	}

	…

	float4 _SpecularTint;
	float _Smoothness;

	…

	float4 MyFragmentProgram (Interpolators i) : SV_TARGET {
		…

		float3 halfVector = normalize(lightDir + viewDir);
		float3 specular = _SpecularTint.rgb * lightColor * pow(
			DotClamped(halfVector, i.normal),
			_Smoothness * 100
		);

		return float4(specular, 1);
	}
```	
# Energy Conservation
```
	float3 specularTint; // = albedo * _Metallic;
	float oneMinusReflectivity; // = 1 - _Metallic;
	//albedo *= oneMinusReflectivity;
	albedo = DiffuseAndSpecularFromMetallic(
		albedo, _Metallic, specularTint, oneMinusReflectivity
	);
```

# Physically-Based Shading
Unity's standard shaders use a PBS approach as well. Unity actually has multiple implementations. 
It decides which to used based on the target platform, hardware, and API level. 
The algorithm is accessible via the UNITY_BRDF_PBS macro, which is defined in UnityPBSLighting. 
BRDF stands for bidirectional reflectance distribution function.

They still compute diffuse and specular reflections, just in a different way than Blinn-Phong. 
Besides that, there also is a Fresnel reflection component. 
This adds the reflections that you get when viewing objects at grazing angles. 
Those will become obvious once we include environmental reflections.
```
float4 MyFragmentProgram (Interpolators i) : SV_TARGET {
	i.normal = normalize(i.normal);
	float3 lightDir = _WorldSpaceLightPos0.xyz;
	float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

	float3 lightColor = _LightColor0.rgb;
	float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;

	float3 specularTint;
	float oneMinusReflectivity;
	albedo = DiffuseAndSpecularFromMetallic(
		albedo, _Metallic, specularTint, oneMinusReflectivity
	);
	
	UnityLight light;
	light.color = lightColor;
	light.dir = lightDir;
	light.ndotl = DotClamped(i.normal, lightDir);
	UnityIndirect indirectLight;
	indirectLight.diffuse = 0;
	indirectLight.specular = 0;

	return UNITY_BRDF_PBS(
		albedo, specularTint,
		oneMinusReflectivity, _Smoothness,
		i.normal, viewDir,
		light, indirectLight
	);
}
```

# Second light/pass
two pass， batch 要加倍，并且不能动态合并
```
Pass {
	Tags {
		"LightMode" = "ForwardAdd"
	}
    Blend One One
    ZWrite Off
	CGPROGRAM

	#pragma target 3.0

	#pragma vertex MyVertexProgram
	#pragma fragment MyFragmentProgram

	#include "My Lighting.cginc"

	ENDCG
}
```
# Point Lights
```
#pragma multi_compile DIRECTIONAL POINT
UnityLight CreateLight (Interpolators i) {
	UnityLight light;
	#if defined(POINT)
		light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
	#else
		light.dir = _WorldSpaceLightPos0.xyz;
	#endif
//	float3 lightVec = _WorldSpaceLightPos0.xyz - i.worldPos;
//	float attenuation = 1 / (dot(lightVec, lightVec));
	UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
	light.color = _LightColor0.rgb * attenuation;
	light.ndotl = DotClamped(i.normal, light.dir);
	return light;
}
```
# Spotlights
Besides directional and point lights, unity also supports spotlights. 
Spotlights are like point lights, except that they are restricted to a cone, instead of shining in all directions.

# Vertex Lights
Rendering a light per vertex means that you perform the lighting calculations in the vertex program. 
The resulting color is then interpolated and passed to the fragment program. 
This is so cheap, that Unity includes such lights in the base pass. 
When this happens, Unity looks for a base pass shader variant with the VERTEXLIGHT_ON keyword.

Vertex lighting is only supported for ** point lights **. So directional lights and spot lights cannot be vertex lights.

By default, Unity decides which lights become pixel lights. 
You can override this by changing a light's Render Mode. Important lights are always rendered as pixel lights, 
regardless of the limit. Lights that are not important are never rendered as pixel lights.

# Spherical Harmonics
The idea behind spherical harmonics is that you can describe all incoming light at some point with a single function. 
This function is defined on the surface of a sphere.
This is supported for all three light types.

# Skybox
天空盒子通过球面谐波也能提供光照