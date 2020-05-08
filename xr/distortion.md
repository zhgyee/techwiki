# Overview
* The larger the field of view, the more distorted the image.  
大视场角度的非对称光学系统，畸变很大，几乎和视场角度的三次方成比例。只有将画面预畸变，才可以消除最终输送进人眼的图像的畸变。

* These optical distortions affect not only the
perceived shapes of virtual objects, but also their perceived depths
and apparent movements.[HMD calibration and its effects on distance judgments](www.cs.utah.edu/percept/papers/Kuhl:2009:HCE-author-version.pdf)
* In a binocular (two-eyed) system, there is an area of visual overlap between the two eyes, which is called binocular overlap. If an object is displayed in both eyes in this area, and if the distortion in one eye is different than the other (for instance, because the object’s distance from center is different), a **blurry** image will often appear.
* Objects of constant size may appear to change size as they move through the visual field.
* IPD、Eye Relief不匹配也会引起畸变，详见[doc-ok](http://doc-ok.org/?p=756)

# How is distortion measured?

Distortion is reported in percentage units. If a pixel is placed at a distance of 100 pixels (or mm or degrees or inches or whichever unit you prefer) and appears as if it at a distance of 110, the distortion at that particular point is (110-100)/100 = 10%.

During the process of optical design, distortion graphs are commonly viewed during the iterations of the design. For instance, consider the distortion graph below:

![Distortion graph. Source: SPIE](https://i0.wp.com/opticalengineering.spiedigitallibrary.org/data/Journals/OPTICE/22108/023001_1_2.png)

以下是通过gameOptics测量的数据，其中`distortion=(real-r-predicted-r)/predicted-r, where real-r=sqrt(real-x*real-x+real-y*real-y)`
```
unit is mm
field unit is degree
i	j	x-field	y-field	r-field	predicted-x	predicted-y	real-x	real-y	distortion
-50	-50	-2.90E+01	-2.90E+01	4.10E+01	-8.09E+02	-8.09E+02	-9.68E+02	-9.68E+02	19.74%
-50	-49	-2.90E+01	-2.84E+01	4.06E+01	-8.09E+02	-7.92E+02	-9.64E+02	-9.44E+02	19.17%

```

# Distortion type
## Radial distortion 
This distortion is caused by the spherical shape of the lens. Light passing through the center of the lens undergoes almost no refraction. So it has almost no radial distortion. Light going through the edges goes through severe bending. So the periphery of the lens causes the most radial distortion. - See more at: http://aishack.in/tutorials/major-physical-defects-cameras/#sthash.emt90Kfm.dpuf

![Radial distortion ](http://aishack.in/static/img/tut/lens-radial-distortion-example.jpg)

## Tangential distortion 
When the lens is not parallel to the imaging plane (the CCD, etc) a tangential distortion is produced. - See more at: http://aishack.in/tutorials/major-physical-defects-cameras/#sthash.emt90Kfm.dpuf

![Tangential distortion ](http://aishack.in/static/img/tut/lens-tangential-distortion.jpg)

Because of this, you get a weird image. In the image below, I'm not sure if you see the distortion. But the CCD plane's top seems to be towards the viewer: 

![](http://aishack.in/static/img/tut/lens-tangential-distortion-example.jpg)

## thin prism distortion
Another error component
is thin prism distortion. It arises from imperfect lens
design and manufacturing, as well as camera assembly.
This type of distortion can be adequately modelled by the
adjunction of a thin prism to the optical system, causing
additional amounts of radial and tangential distortions.

## Perspective distortion
Perspective projection is generally not a shape preserving
transformation. Only lines are mapped as lines on the
image plane. Two- and three-dimensional objects with a
non-zero projection area are distorted if they are not coplanar
with the image plane. This is true for arbitrary shaped
features.

Perspective projection distorts the shape of the circular
features in the image plane depending on the angle
and displacement between the object surface and the image
plane. Only when the surface and the image plane are parallel,
projections remain circular.

# Distortion calibration
The goal of HMD calibration is to build and solve a
computational model involving HMD parameters.

# Distortion correction methods
In most VR software, this reverse distortion is performed by rendering each eye-camera into a separate render target and then warping that image in a post process effect – 
 * either in a *pixel shader*, 
 * or by projecting the render target onto a warped mesh – and rendering the final output to the screen.
 * [Brian](https://ustwo.com/blog/vr-distortion-correction-using-vertex-displacement) demonstrates a technique which performs the distortion ahead of time in the *vertex shader* of each object in the scene

## Fragment based solution (bad)
The simplest way to using two pass rendering. First, we render the left and right eyes onto a texture, and then process that texture with a fragment (pixel) shader, moving each pixel inward in relation to the centroid of the eye
## Mesh based solution (better)
Rather than processing each pixel separately, we distort the vertices of a relatively sparse mesh (40x20 works well).
This can save some direct computation and let the GPU do a fair amount of interpolation. Rather than having to apply to every single pixel (1920 * 1080 ~= 2e6), we do the calculation for every vertex in the mesh (40 * 20 = 800). The result is a significant reduction (3 magnitudes or so) of computation, and a nice boost in performance. The WebVR Polyfill currently implements this approach.
## Vertex displacement based solution (best)
In this approach, the geometry itself is distorted using a custom vertex shader. The idea is that knowing the position of the camera, we can displace vertices in such a way that the resulting 2D render is already barrel distorted. In this case, no shader pass is needed, and we save the expensive step of copying the rendering into a texture.
#  Barrel distortion correctionperformance
Fragment based solution is the most accurate approach we can use to calculate the distortion. **Unfortunately it is also very expensive in terms of GPU usage. ** The vertex shader runs quickly since we only have to process six points (two triangles to output a rectangle). On the other side, the fragment shader has to do the transformation for every pixel on the screen. For a 1920 x 1080 pixel display this becomes 2073600 calculations and texture lookups.

The advantage of mash base solution is that we only have to do this once at initialization time; because the lens parameters don’t change over time, we can reuse the mesh on every frame. This makes up our first part of the optimization – the pre-calculation.

The second part is the approximation: in this case, it is defined by the mesh resolution. Everything between the mesh points will be interpolated. Having a smaller mesh resolution will produce an image with higher quality; having a bigger mesh resolution will be faster. So what are the savings by using a mesh? Using a 32 pixel mesh results in the following for our 1920 x 1080 pixel display:`(1920, 1080) / 32 = (60, 33.75)`    
**This will still do the texture lookups, but will avoid doing the transformations.** We save a lot of processing power and on higher resolution displays the savings will be even bigger. Here I have summarized the savings again for our Full HD display example:
![gpu_calculation](/uploads/e7441ad69e68c1303692258ae84c37b5/gpu_calculation.PNG)
# perspect project distortion
```math
\begin{aligned}
\text{when the display has the aspect ratio a, a diameter of d inch and a distance to the viewer of x meters} \\
i = \frac{0.0254d}{2\sqrt{1+a^2}x} \\
\text{half height } h = tan(\frac{FOV_y}{2}) \\
p(b) = \frac{b}{z-n_xb_x^2-n_yb_y^2} \text{ and inverse } b(p) = \frac{zp}{\frac{1}{2}+\sqrt{\frac{1}{4}+z(n_xp_x^2+n_yp_y^2)}}\\
z=\frac{1}{2}+\frac{1}{2}\sqrt{1+h^2s^2(1+a^2)} \\
n_x = a^2c^2n_y \\
n_y=\frac{(z-1)}{1+a^2c^2} \\
\text{s is the strength of the distortion effect, where 0 means no added distortion, and 1 means full stereographic-to-perspective re-projection.} \\
s=\sqrt{\frac{h^2-i^2}{h^2(1+i^2(1+a^2))}} \\
\end{aligned}
```
[see details](http://www.decarpentier.nl/lens-distortion)

# 一种畸变模型
参考论文：《A Method of Computational Correction for Optical Distortion in Head-Mounted Displays》

```math
\begin{aligned}
R=mR_s \\
R_v=D(R_s) \\
R_v=R+\Delta R \\
\Delta R=kR^3+hR^5+\ldots \\
R_v=D(R_s)=mR_s+k(mR_s)^3 \\
distortionRate=100 \frac{k(mR_s)^3}{mR_s}=100k(mR_s)^2 \\
R_i=D^{-1}(R) \text{    预畸变点在屏幕的位置}\\
R_i=D^{-1}(R)=\sqrt[3]{-\frac{q}{2}+\sqrt{\frac{p}{3}^3 + \frac{q}{2}^3}} + \sqrt[3]{-\frac{q}{2}-\sqrt{\frac{p}{3}^3 + \frac{q}{2}^3}}\text{  where  }p=\frac{1}{m^2k} \text{ and } q=-\frac{R}{m^3k}
\end{aligned}
```

# Brown-Conray distortion correction model
```
// These coefficients control the degree of distortion that
// is applied on the rendertargets, per channel. The notation
// is the same as in the original Brown-Conray distortion
// correction model.
struct DistortionCoefficients
{
    // Radial distortion coefficients
    float k1; // Central
    float k2; // Edge
    float k3; // Fine

    // Tangential distortion coefficients
    float p1; // Horizontal
    float p2; // Vertical
};
// Computes the distorted texel coordinate given the
// position on the image plane.
vec2 compute_distortion(float x, float y,
                        vec2 distort_centre,
                        DistortionCoefficients coefficients,
                        float tex_coord_factor)
{
    float k1 = coefficients.k1;
    float k2 = coefficients.k2;
    float k3 = coefficients.k3;
    float p1 = coefficients.p1;
    float p2 = coefficients.p2;

    // We need to correct for aspect ratio to ensure that
    // the distortion appears circular on the device.
    y /= View_Aspect_Ratio;

    float dx = x - distort_centre.x;
    float dy = y - distort_centre.y;
    float r2 = dx * dx + dy * dy;
    float r4 = r2 * r2;
    float r6 = r4 * r2;

    float radial_x = x * (k1 * r2 + k2 * r4 + k3 * r6);
    float radial_y = y * (k1 * r2 + k2 * r4 + k3 * r6);

    float tangential_x = p1 * (r2 + 2.0f*x*x) + 2.0f*p2*x*y;
    float tangential_y = p2 * (r2 + 2.0f*y*y) + 2.0f*p1*x*y;

    float distorted_x = x + radial_x + tangential_x;
    float distorted_y = y + radial_y + tangential_y;

    float result_x = 0.5f + tex_coord_factor * distorted_x;
    float result_y = 0.5f + tex_coord_factor * distorted_y * View_Aspect_Ratio;

    return vec2(result_x, result_y);
}
```
# Distortion mapping
![texcoord](/uploads/10bb1d84123eb58590fc5dcc35df1bfa/texcoord.png)

# Catmull–Rom spline
```
//通过tanSqr / maxTanSqrt得出点所在的区间ix以及小数部分dx，其中ks为10个控制点，可以理解为镜片上不同园的半径，通过Catmull–Rom可以插值出该区间内的任意园的半径，也即distortion scale
float EvalCatmullRomSpline(const std::vector<float>& Ks, const float& tanSqr, float maxTanSqr)
{
	float x = tanSqr / maxTanSqr * 10.f;
	int ix = std::floor(x);
	if(ix > 10)
	{
		ix = 10;
	}
	float dx = x - ix;
	float p0 = 0.f;
	float p1 = 0.f;
	float m0 = 0.f;
	float m1 = 0.f;
	switch(ix)
	{
		case 0:
			{
				p0 = Ks[0];
				p1 = Ks[1];
				m0 = Ks[1] - Ks[0];
				m1 = 0.5f * (Ks[2] - Ks[0]);
			}
			break;
		case 9:
			{
				p0 = Ks[ix];
				p1 = Ks[ix+1];
				m0 = 0.5f * (Ks[ix+1] - Ks[ix-1]);
				m1 = Ks[ix+1] - Ks[ix];
			}
			break;
		case 10:
			{
				p0 = Ks[ix];
				m0 = Ks[ix] - Ks[ix-1];
				p1 = p0 + m0;
				m1 = m0;
			}
			break;
		default:
			{
				p0 = Ks[ix];
				p1 = Ks[ix+1];
				m0 = 0.5f * (Ks[ix+1] - Ks[ix-1]);
				m1 = 0.5f * (Ks[ix+2] - Ks[ix]);
			}
			break;
	}

	float omt = 1.f - dx;
	return (p0*(1.f + 2.f*dx) + m0*dx) * omt*omt + (p1*(1.f + 2.f*omt) - m1*omt) *dx*dx;
}
```
We can write the interpolation polynomial as $`p(t)=h_{00}(t)p_0+h_{10}(t)m_0+h_{01}(t)p_1+h_{11}(t)m_1`$, where
```math
\begin{aligned}
h_{00}(t)=(1+2t)(1-t)^2 \\
h_{10}(t)=t(1-t)^2 \\
h_{01}(t)=t^2(3-2t) \\
h_{11}(t)=t^2(t-1)
\end{aligned}
```
Catmull–Rom spline --> For tangents chosen to be 
$`m_n=\frac{p_{n+1}-p_{n-1}}{t_{n+1}-t_{n-1}}`$

![Catmull_Rom-spline](/uploads/017d0f921703a72f07b96bd17c276b17/Catmull_Rom-spline.PNG)

[Cubic Hermite spline](https://en.wikipedia.org/wiki/Cubic_Hermite_spline)

# 畸变相关变量
## IPD(lens separation)
最终表现为畸变中心（光学中心点的位置）
## FOV

## screen w/h in meter
屏幕pixel到meter转换
## MeterPerTanAngleAtCenter
为理想的光学系统焦距，通过opticGame进行光线追踪可计算出，示例如下：
```
i	j	X-Field	    Y-Field	    R-Field	    Predicted x	 Predicted yPredicted r	Real x	    Real y	    Real r	  Distortion idealmpt	real mpt    mptdistortion	
0	-50	0.00E+00	-3.07E+01	3.07E+01	0.00E+00	-2.67E+01	2.67E+01	0.00E+00	-2.39E+01	2.39E+01	-10.56%	4.50E-02	4.03E-02	-1.06E+01
0	-49	0.00E+00	-3.02E+01	3.02E+01	0.00E+00	-2.62E+01	2.62E+01	0.00E+00	-2.35E+01	2.35E+01	-10.18%	4.50E-02	4.04E-02	-1.02E+01
0	-48	0.00E+00	-2.97E+01	2.97E+01	0.00E+00	-2.56E+01	2.56E+01	0.00E+00	-2.31E+01	2.31E+01	-9.81%	4.50E-02	4.06E-02	-9.81E+00
0	-47	0.00E+00	-2.91E+01	2.91E+01	0.00E+00	-2.51E+01	2.51E+01	0.00E+00	-2.27E+01	2.27E+01	-9.44%	4.50E-02	4.08E-02	-9.44E+00
```
理想焦距与实际焦距之前的畸变与像素位置的畸变是一致的，也即两者都是同一套非线性关系。

## 畸变测量值
通过光学测量法获取畸变前后空间点的对应关系表。


# reference
[Software_correction](https://en.wikipedia.org/wiki/Distortion_(optics)#Software_correction)
[ARM VR SDK](/armvr.md)

