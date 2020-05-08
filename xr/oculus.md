
# see also
* [gearvrf](gearvrf.md)
* [ovr](ovr.md)

# 调试模式
注释掉AndroidManifest.xml中的vronly metadata，然后编译
```
		<meta-data android:name="com.samsung.android.vr.application.mode" android:value="vr_only"/>
```
可以使用gapid进行intercept低层的图形api

# timewarp
## shader
vertex shader(1.5.0)
```
"#version 300 es
#define LAYER_VERTEX_CLIP 1
#define LAYER_TEX_COORD_VERTEX_PROJECT 1

#if __VERSION__ < 300 /* needed only for samplerExternalOES */
	#define in attribute
	#define out varying
#endif

	uniform highp mat4 WarpT0;
	uniform highp mat4 WarpT1;
	uniform highp vec4 TextureRectVert;
	uniform highp vec4 TextureRectMarginVert;


#if defined(LAYER_REMAP_2D_SCALE_BIAS)
	uniform highp vec4 Remap2DScaleBiasVert;
#endif

	in vec4 Position;

	in vec2 TanAngleG;		// green
#if ! defined( LAYER_SKIP_CHROMATIC_ABERRATION_CORRECTION )
	in vec2 TanAngleR;		// red
	in vec2 TanAngleB;		// blue
#endif

#if defined(LAYER_EQUIRECT)
	out lowp  float		CalculateInFragmentShader;
#endif

#if defined(LAYER_HEMICYL)
	// hard coded to 180 degrees around
	highp vec2 Hemicyl( highp vec3 p )
	{
	    // Find the cylinder hit point
	    // The viewpoint relative to the normalized cylinder center
	    // is encoded in the translation part of the texture matrix.
        highp float a = p.x * p.x + p.z * p.z;
        highp float b = 2.0 * ( WarpT0[3][0]*p.x + WarpT0[3][2]*p.z );
        highp float c = WarpT0[3][0]*WarpT0[3][0] + WarpT0[3][2]*WarpT0[3][2] - WarpT0[3][3]*WarpT0[3][3];
        highp float f = (-b + sqrt(b*b-4.0*a*c)) / (2.0*a);
        p = vec3(WarpT0[3][0],WarpT0[3][1],WarpT0[3][2]) + p * f;

	    // Convert the cylinder hit point into a texcoord
		highp float s = 0.5 + atan( p.x, -p.z ) / 3.1415927;
        highp float t = -p.y + 0.5;

		highp vec2 st = vec2(s, t);
		#if defined(LAYER_REMAP_2D_SCALE_BIAS)
			st = st * Remap2DScaleBiasVert.xy + Remap2DScaleBiasVert.zw;
		#endif

		return st;
	}
#endif

#if defined(LAYER_EQUIRECT)
	highp float Arctangent2( highp float y, highp float x )
	{
		highp float bias = 0.0;
		if ( x < 0.0 )
		{
			bias = y >= 0.0 ? 3.1415927 : -3.1415927;
		}
		return atan( y / x ) + bias;
	}
	highp vec2 Equirect( highp vec3 p )
	{
		highp float xz = sqrt( p.x * p.x + p.z * p.z );
		highp float lat = -atan( p.y / xz ); // don't need Arctangent2 here since xz is never negative
		highp float t = lat / 3.1415927 + 0.5;
		highp float s = Arctangent2( p.x, -p.z ) / (2.0 * 3.1415927) + 0.5;
		highp vec2 st = vec2(s, t);
		float danger = 0.012 / (1.0 - abs(2.0 * st.y - 1.0));
		CalculateInFragmentShader += ( st.x < danger || st.x > 1.0 - danger || st.y < 0.25 || st.y > 0.75 ) ? 1.0 : 0.0;
		#if defined(LAYER_REMAP_2D_SCALE_BIAS)
			st = st * Remap2DScaleBiasVert.xy + Remap2DScaleBiasVert.zw;
		#endif
		return st;
	}
#endif

	void Clip( vec3 p, vec4 rect )
	{
	#if defined(LAYER_VERTEX_CLIP)
		#if defined(LAYER_HEMICYL)
			p.xy = Hemicyl( p );
			p.z = 1.0;
		#endif
		float xc = rect.x;
		float yc = rect.y;
		float w2 = rect.z;
		float h2 = rect.w;
		float push = max( 0.0, 1.0 - p.z );
		#define SLOP TextureRectMarginVert
		push = max( push, SLOP.x * abs( p.x / p.z - xc ) / w2 );
		push = max( push, SLOP.y * abs( p.y / p.z - yc ) / h2 );
		gl_Position.z += push;
	#endif // LAYER_VERTEX_CLIP
	}

	#if defined(LAYER_TEX_COORD_VERTEX_PROJECT)
		#define TexCoordType vec2
		#if defined(LAYER_HEMICYL)
			vec2 Project( vec3 coord ) { return Hemicyl( coord ); }
		#else
			vec2 Project( vec3 coord ) { return coord.xy / coord.z; }
		#endif
	#else
		#define TexCoordType vec3
		vec3 Project( vec3 coord ) { return coord; }
	#endif

	out highp TexCoordType TexCoordG;
#if ! defined( LAYER_SKIP_CHROMATIC_ABERRATION_CORRECTION )
	out highp TexCoordType TexCoordR;
	out highp TexCoordType TexCoordB;
#endif

#if defined(LAYER_EQUIRECT)
	out highp vec2		TexCoord2G;
	#if ! defined( LAYER_SKIP_CHROMATIC_ABERRATION_CORRECTION )
		out highp vec2 TexCoord2R;
		out highp vec2 TexCoord2B;
	#endif
#endif

	void main()
	{
		gl_Position = Position;
	#if defined( LAYER_GLOBAL_SHUTTER )
		mat3 t0 = mat3(WarpT1);
		mat3 t1 = mat3(WarpT1);
	#else
		mat3 t0 = mat3(WarpT0);
		mat3 t1 = mat3(WarpT1);
	#endif
	#if defined( LAYER_GLOBAL_SHUTTER )
		float frac = 0.0;
	#elif defined( LAYER_TOP_DOWN_SCANOUT )
		float frac = fract( 0.99999 * ( ( gl_Position.y * -0.5 + 0.5 ) / gl_Position.w ) );
	#else
		float frac = fract( 0.99999 * ( gl_Position.x / gl_Position.w ) );
	#endif

		vec3 tcg = mix( t0 * vec3(TanAngleG,-1), t1 * vec3(TanAngleG,-1), frac );
		Clip( tcg, TextureRectVert );
		TexCoordG = Project( tcg );
		#if defined( LAYER_EQUIRECT )
			CalculateInFragmentShader = 0.0;
			TexCoord2G = Equirect( TexCoordG );
		#endif
	#if ! defined( LAYER_SKIP_CHROMATIC_ABERRATION_CORRECTION )
		vec3 tcr = mix( t0 * vec3(TanAngleR,-1), t1 * vec3(TanAngleR,-1), frac );
		vec3 tcb = mix( t0 * vec3(TanAngleB,-1), t1 * vec3(TanAngleB,-1), frac );
		TexCoordR = Project( tcr );
		TexCoordB = Project( tcb );
		#if defined( LAYER_EQUIRECT )
			TexCoord2R = Equirect( TexCoordR );
			TexCoord2B = Equirect( TexCoordB );
		#endif
	#endif
	}
"
```
fragment shader 1.5.0
```

"#version 300 es
#define SamplerType mediump sampler2DArray
uniform SamplerType Texture0;
#define LAYER_SOURCE_sampler2DArray 1
#define LAYER_VERTEX_CLIP 1
#define LAYER_TEX_COORD_VERTEX_PROJECT 1

#if __VERSION__ < 300 /* needed only for samplerExternalOES */
	#define in varying
	#define fragColor gl_FragColor
#else
	out mediump vec4 fragColor;
#endif

	uniform lowp vec4 ColorScale;
	uniform lowp float Eye;

#if defined(LAYER_REMAP_2D_SCALE_BIAS)
	uniform mediump vec4 Remap2DScaleBias;
#endif

#if defined(LAYER_OFFCENTER_CUBE_MAP)
	uniform mediump vec4 Offcenter;
#endif

#if defined(LAYER_TEX_COORD_VERTEX_PROJECT)
	#define TexCoordType vec2
#else
	#define TexCoordType vec3
#endif

#if defined(LAYER_CUSTOM_TEXTURE_FUNC) && defined(TextureFunc)
	// NOP, will be defined in custom shader prefix. But only if the custom sampler contains a TextureFunc macro.
#elif __VERSION__ < 300 /* needed only for samplerExternalOES */
	#define TextureFunc texture2D
#else
	#define TextureFunc texture
#endif

#if defined(LAYER_EQUIRECT)
	in lowp	float		CalculateInFragmentShader;

	highp float Arctangent2( highp float y, highp float x )
	{
		highp float bias = 0.0;
		if ( x < 0.0 )
		{
			bias = y >= 0.0 ? 3.1415927 : -3.1415927;
		}
		return atan( y / x ) + bias;
	}
	highp vec2 Equirect( highp vec3 p )
	{
		highp float xz = sqrt( p.x * p.x + p.z * p.z );
		highp float lat = -atan( p.y / xz ); // don't need Arctangent2 here since xz is never negative
		highp float t = lat / 3.1415927 + 0.5;
		highp float s = Arctangent2( p.x, -p.z ) / (2.0 * 3.1415927) + 0.5;
		highp vec2 st = vec2(s, t);
		#if defined(LAYER_REMAP_2D_SCALE_BIAS)
			st = st * Remap2DScaleBias.xy + Remap2DScaleBias.zw;
		#endif
		return st;
	}
#endif

#if defined(LAYER_CUSTOM_TEXTURE_FUNC)
	// NOP, will be defined in custom shader prefix.
#elif defined(LAYER_SOURCE_samplerCube)
	highp vec3 Remap( highp vec3 tc )
	{
	#if defined(LAYER_OFFCENTER_CUBE_MAP)
		return normalize(tc) + Offcenter.xyz;
	#else
		return tc;
	#endif
	}
#else
	#if defined( LAYER_TEX_RECT_CLIP ) || defined( LAYER_TEX_COORD_CLAMP_LEFT ) || defined( LAYER_TEX_COORD_CLAMP_BOTTOM ) || defined( LAYER_TEX_COORD_CLAMP_RIGHT ) || defined( LAYER_TEX_COORD_CLAMP_TOP )
		uniform mediump vec4 TextureRectFrag; // lower-left, upper-right
	#endif

	highp vec2 Rect( highp vec2 tc )
	{
	#if defined( LAYER_TEX_RECT_CLIP )
		if ( any( lessThan( tc, TextureRectFrag.xy ) ) || any( lessThan( TextureRectFrag.zw, tc ) ) ) { discard; }
	#else
		#if defined( LAYER_TEX_COORD_CLAMP_LEFT )
			tc.x = max( tc.x, TextureRectFrag.x );
		#endif
		#if defined( LAYER_TEX_COORD_CLAMP_BOTTOM )
			tc.y = max( tc.y, TextureRectFrag.y );
		#endif
		#if defined( LAYER_TEX_COORD_CLAMP_RIGHT )
			tc.x = min( tc.x, TextureRectFrag.z );
		#endif
		#if defined( LAYER_TEX_COORD_CLAMP_TOP )
			tc.y = min( tc.y, TextureRectFrag.w );
		#endif
	#endif
		return tc;
	}

	highp vec2 Project( highp vec2 tc ) { return tc; }
	highp vec2 Project( highp vec3 tc ) { return tc.xy / tc.z; }

	#if defined( LAYER_SOURCE_sampler2DArray )
		#define BundledCoordType vec3
		#define BUNDLE_COORD( tc ) vec3( tc, Eye )
	#else
		#define BundledCoordType vec2
		#define BUNDLE_COORD( tc ) ( tc )
	#endif


	#if defined( LAYER_EQUIRECT )
		highp BundledCoordType RemapEquirect( highp vec3 tc, highp vec2 tc2 )
		{
			if ( CalculateInFragmentShader != 0.0 )
			{
				tc2 = Equirect( tc );
			}
			return BUNDLE_COORD( Rect( tc2 ) );
		}
	#else
		highp BundledCoordType Remap( highp TexCoordType tc )
		{
			highp vec2 tc2 = Project( tc );
			highp vec2 tc3 = Rect( tc2 );
			highp BundledCoordType tc4 = BUNDLE_COORD( tc3 );
			return tc4;
		}
	#endif
#endif

	in highp TexCoordType TexCoordG;
#if ! defined( LAYER_SKIP_CHROMATIC_ABERRATION_CORRECTION )
	in highp TexCoordType TexCoordR;
	in highp TexCoordType TexCoordB;
#endif

#if defined( LAYER_EQUIRECT )
	in highp vec2		TexCoord2G;
	#if ! defined( LAYER_SKIP_CHROMATIC_ABERRATION_CORRECTION )
		in highp vec2		TexCoord2R;
		in highp vec2		TexCoord2B;
	#endif
#endif

#if defined( LAYER_SHOW_TEXTURE_DENSITY ) && defined( LAYER_SOURCE_samplerCube )
	uniform mediump samplerCube Texture1;
#elif defined( LAYER_SHOW_TEXTURE_DENSITY )
	uniform mediump sampler2D Texture1;
#endif

#if defined( LAYER_EQUIRECT )
		#define REMAP_ARGS( a, b ) RemapEquirect( a, b )
#else
	#define REMAP_ARGS( a, b ) Remap( a )
#endif

	void main()
	{
	#if defined( LAYER_SHOW_COMPLEXITY )
		fragColor = vec4( 0.25, 0.25, 0.25, 0.25 );
	#elif defined( LAYER_SHOW_TEXTURE_DENSITY ) && defined( LAYER_SOURCE_samplerCube )
		highp float bias = log2( float( textureSize( Texture0, 0 ).x ) ) - log2( 4.0 );
		fragColor = TextureFunc( Texture1, REMAP_ARGS( TexCoordG, TexCoord2G ).xyz, bias );
	#elif defined( LAYER_SHOW_TEXTURE_DENSITY )
		highp vec2 uv = REMAP_ARGS( TexCoordG, TexCoord2G ).xy * vec2( textureSize( Texture0, 0 ).xy ) * vec2( 1.0/4.0, 1.0/4.0 );
		fragColor = TextureFunc( Texture1, uv );
	#elif ! defined( LAYER_SKIP_CHROMATIC_ABERRATION_CORRECTION )
		lowp vec4 color1r = TextureFunc( Texture0, REMAP_ARGS( TexCoordR, TexCoord2R ) );
		lowp vec4 color1g = TextureFunc( Texture0, REMAP_ARGS( TexCoordG, TexCoord2G ) );
		lowp vec4 color1b = TextureFunc( Texture0, REMAP_ARGS( TexCoordB, TexCoord2B ) );
		lowp vec4 color1 = vec4( color1r.x, color1g.y, color1b.z, color1g.w );
		fragColor = color1 * ColorScale;
	#else
		fragColor = TextureFunc( Texture0, REMAP_ARGS( TexCoordG, TexCoord2G ) ) * ColorScale;
	#endif
	#if defined( LAYER_EMULATE_FRAMEBUFFER_SRGB )
		fragColor.rgb = pow( fragColor.rgb, vec3( 1.0 / 2.2 ) );
	#endif
	#if defined( LAYER_HDMI_LIMITED_COLOR_RANGE )
		fragColor.rgb = fragColor.rgb * ( ( 235.0 - 16.0 ) / 255.0 ) + ( 16.0 / 255.0 );
	#endif
	}
"
```
