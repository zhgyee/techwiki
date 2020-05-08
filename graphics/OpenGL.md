# 目录

[MSAA](MSAA.md)

# 3D Graphics Rendering Pipeline
![RenderingPipeline](https://www.opengl.org/wiki_132/images/RenderingPipeline.png)

[Rendering_Pipeline_Overview](https://www.opengl.org/wiki/Rendering_Pipeline_Overview)

[3D Graphics Rendering Pipeline](http://www.ntu.edu.sg/home/ehchua/programming/opengl/images/Graphics3D_Pipe.png)

The OpenGL rendering pipeline works in the following order:
* Prepare vertex array data, and then render it
* Vertex Processing:
 * Each vertex is acted upon by a Vertex Shader. Each vertex in the stream is processed in turn into an output vertex.
 * Optional primitive tessellation stages.
 * Optional Geometry Shader primitive processing. The output is a sequence of primitives.
* Vertex Post-Processing, the outputs of the last stage are adjusted or shipped to different locations.
 * Transform Feedback happens here.
 * Primitive Clipping,
 * the perspective divide, 
 * and the viewport transform to window space.
* Primitive Assembly
* Scan conversion and primitive parameter interpolation, which generates a number of Fragments.
* A Fragment Shader processes each fragment. Each fragment generates a number of outputs.
* Per-Sample_Processing:
 * Scissor Test
 * Stencil Test
 * Depth Test
 * Blending
 * Logical Operation
 * Write Mask

## vertex processing
![Coordinates Transformation](http://www.ntu.edu.sg/home/ehchua/programming/opengl/images/Graphics3D_CoordTransform.png)

* Model Transform (or Local Transform, or World Transform)
* View Transform
* Projection Transform - Perspective Projection
* Projection Transform - Orthographic Projection

## Rasterization
![Rasterization](http://www.ntu.edu.sg/home/ehchua/programming/opengl/images/Graphics3D_Rasterization.png)
In this rasterization stage, each primitive (such as triangle, quad, point and line), which is defined by one or more vertices, are raster-scan to obtain a set of fragments enclosed within the primitive. Fragments can be treated as 3D pixels, which are aligned with the pixel-grid. The 2D pixels have a position and a RGB color value. The 3D fragments, which are interpolated from the vertices, have the same set of attributes as the vertices, such as position, color, normal, texture.
The substages of rasterization include:

* viewport transform
* clipping
* perspective division
* back-face culling
* scan conversion. 

The rasterizer is not programmable, but configurable via the directives.

## Fragment Processing
After rasterization, we have a set of fragments for each primitive. A fragment has a position, which is aligned to the pixel-grid. It has a depth, color, normal and texture coordinates, which are interpolated from the vertices.
The fragment processing focuses on the __texture and lighting__ , which has the greatest impact on the quality of the final image. 
The operations involved in the fragment processor are:

* The first operation in fragment processing is texturing.
* Next, primary and secondary colors are combined, and fog calculation may be applied.
* The optional scissor test, alpha test, stencil test, and depth-buffer test are carried out, if enabled.
* Then, the optional blending, dithering, logical operation, and bitmasking may be performed.

# vertex transform
![vertex transform](http://www.scratchapixel.com/images/upload/perspective-matrix/vertex-transform-pipeline.png?)

#homogeneous coordinates

if the w-component is not equal to 1, then (x, y, z, w) corresponds to Cartesian coordinates of (x/w, y/w, z/w). If w=0, it represents a vector, instead of a point (or vertex).


# GL error leak issue
// glFinish() need dequeue buffer, and it is not 100% success   373
// It generates gl error sometimes, this error will be there374
// until glGetError called. Call GLUtils::dumpGLErrors to clean 375
// the error in case it leaks to other functions376
GLUtils::dumpGLErrors();

# FBO
* render to texture
* offscreen rendering

There are two types of framebuffer-attachable images; texture images and renderbuffer images. If an image of a texture object is attached to a framebuffer, OpenGL performs "render to texture". And if an image of a renderbuffer object is attached to a framebuffer, then OpenGL performs "offscreen rendering".
##  Read texture data with FBO ## 
```
GLuint fbo;
glGenFramebuffers(1, &fbo);
glBindFramebuffer(GL_FRAMEBUFFER, fbo);
glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texId, 0);

unsigned char * buf = (unsigned char *) malloc(eyeResolution * eyeResolution * 8);
glReadPixels(0, 0, eyeResolution, eyeResolution, GL_RGBA, GL_UNSIGNED_BYTE, (void *) buf);
glDeleteFramebuffers(1, &fbo);
```
**Note:Another way to read texture data is using BufferConsumer::getCurrentBuffer() API in native space**

http://www.songho.ca/opengl/gl_fbo.html

# Shader
* texture2D() --2D texture lookup
返回请求位置的像素值。

http://www.shaderific.com/glsl-functions/

# Pixel vs. Fragment
Pixels refers to the dots on the display, which are aligned in a 2-dimensional grid of a certain rows and columns corresponding to the display's resolution. A pixel is 2-dimensional, with a `(x, y)` position and a RGB color value (there is no alpha value for pixels). The purpose of the Graphics Rendering Pipeline is to produce the color-value for all the pixels for displaying on the screen, given the input primitives.

In order to produce the grid-aligned pixels for the display, the rasterizer of the graphics rendering pipeline, as its name implied, takes each input primitive and perform raster-scan to produce a set of grid-aligned fragments enclosed within the primitive. A fragment is 3-dimensional, with a `(x, y, z)` position. The (x, y) are aligned with the 2D pixel-grid. The z-value (not grid-aligned) denotes its depth. The z-values are needed to capture the relative depth of various primitives, so that the occluded objects can be discarded (or the alpha channel of transparent objects processed) in the output-merging stage.
Fragments are produced via interpolation of the vertices. Hence, a fragment has all the vertex's attributes such as color, fragment-normal and texture coordinates.

# glViewport vs glScissor
They operate at two completely different parts of the graphics pipeline.

glViewport actually specifies a transformation, and it's a transformation that happens after the vertex shader but before the fragment shader. If it helps to see where it conceptually fits in, think in terms of it being part of the transforms that are used to get your vertex data from world space to screen space (i.e. it's relatively closely related to modelview and projection).

Scissor test happens after the fragment shader, together with all of the other per-fragment operations that happen at that time, such as blending, depth/stencil, etc. When a fragment is tested by the scissor test, it has therefore already been through the viewport transformation.

Yes, scissor test can be faster can stencil because it's a simple accept/reject based on a fragment's screen space coords, whereas stencil needs to compare with the current value in the stencil buffer, possibly increment or decrement that current value, also take into account the results of the depth test, and so on.

So putting all of that together you can see why scissor test exists. It gives you the ability to constrain per-fragment ops to a rectangular portion of the screen, but without actually modifying the current viewport transform.

GPU will discard the fragments outside the scissor rectangle and draw nothing. With the assumption that the buffer was fully glCleared, and, no need to readback the previous frame.

# texture
## texture2DProj
The texture2DProj() allows us to directly exploit the projected textures coordinates stored in gl_TexCoord[0]. The call to texture2DProj() could be remplaced by a call to texture2D() but in that case we have to divide the {s, t} coordinates by the {q} one as the following code shows it:
```
if( gl_TexCoord[0].q>0.0 )
{
  vec2 projCoords = gl_TexCoord[0].st / gl_TexCoord[0].q;
  vec4 ProjMapColor = texture2D(projMap, projCoords);
  final_color += ProjMapColor*lambertTerm;			
}
```
[Projective Texture Mapping](http://www.ozone3d.net/tutorials/glsl_texturing_p08.php)
[OpenGL 4.0 GLSL 实现 投影纹理映射（Projective Texture Mapping）](http://blog.csdn.net/zhuyingqingfen/article/details/19331721)

## glTexSubImage2D
```
	const int rowPitch = textureWidth * 4;
	// Just allocate a system memory buffer here for simplicity
	unsigned char* data = new unsigned char[rowPitch * textureHeight];
//change byte data
	GLuint gltex = (GLuint)(size_t)(textureHandle);//textureHandle is external created tex name
	// Update texture data, and free the memory buffer
	glBindTexture(GL_TEXTURE_2D, gltex);
	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, textureWidth, textureHeight, GL_RGBA, GL_UNSIGNED_BYTE, data);
	delete[](unsigned char*)data;
```

# 透视收缩
![](http://img.blog.csdn.net/20150514145737857?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvemh1eWluZ3FpbmdmZW4=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

齐次裁剪空间坐标系（范围  -1<=x <=1,-1<=y<=1,-1<=z <=1, )是左手坐标系，为什么？ 其实也很好理解，如上图 ， A和B点经过投影变换后其x坐标是一样的（不再是投影平截体中的那种相对关系）， 而近裁剪面上的点的z坐标经过投影变换后变为-1 ， 而远裁剪面上的z坐标为1 ，所以齐次裁剪空间坐标系的z轴的正方向正好和相机坐标系中的z轴正方向是相反的。
经过透视投影后，每个顶点的x和y坐标还要除以其z坐标，这个除法是产生透视收缩的方法。

# glGetIntegerv
通过glGetIntegerv可以获取到gl current state
```
  //Save current state
  GLint previousFBO, previousRenderBuffer, previous_program;
  glGetIntegerv(GL_FRAMEBUFFER_BINDING, &previousFBO);
  glGetIntegerv(GL_RENDERBUFFER_BINDING, &previousRenderBuffer);
  glGetIntegerv(GL_CURRENT_PROGRAM, &previous_program);
```
# glClear

The application should always call glClear() for every attachment at the start of each render target's rendering sequence, provided that the previous contents of the attachments are not needed, of course. This explicitly tells the driver we do not need the previous state, and thus we avoid reading it back from memory, as well as putting any undefined buffer contents into a defined "clear color" state.

# glInvalidateFramebuffer
The final requirement placed on the application for efficient use of FBOs in the OpenGL ES API is that it should tell the driver which of the color / depth / stencil attachments are simply transient working buffers, the value of which can be discarded **at the end of rendering the current render pass** . For example, nearly every 3D render will use color and depth, but for most applications the depth buffer is transient and can be safely invalidated. Failure to invalidate the unneeded buffers may result in them being written back to memory, wasting memory bandwidth and increasing energy consumption of the rendering process.    
  Therefore transient buffers in frame N should be indicated by calling glInvalidateFramebuffer() before unbinding the FBO in frame N.

大多数内容拥有深度缓冲和模板缓冲，但帧渲染结束后就不必再保留其内容。如果开发人员告诉 Mali 驱动程序不需要保留深度缓冲和模板缓冲2— 理想方式是通过调用  glDiscardFramebufferEXT (OpenGL ES 2.0) 或 glInvalidateFramebuffer (OpenGLES 3.0)，**虽然在某些情形中可由驱动程序推断 — 那么区块的深度内容和模板内容也就彻底不用写回到主内存中**。我们又大幅节省了带宽和功耗！
# blending
```
// Enable blending
glEnable(GL_BLEND);
glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
```
## Caveat

Doing so will work ( more on this in the next section ), but :

* You will be fillrate limited. That is, each fragment will be written 10, 20 times, maybe more. This is way too much for the poor memory bus. Usually the depth buffer allows to reject enough “far” fragments, but here, you explicitly sorted them, so the depth buffer is actually useless.
* You will be doing this 4 times per pixel ( we use 4xMSAA ), except if you use some clever optimisation
* Sorting all the transparent triangles takes time
* If you have to switch your texture, or worse, your shader, from triangle to triangle, you’re going into deep performance trouble. Don’t do this.

A good enough solution is often to :

* Limit to a maximum the number of transparent polygons
* Use the same shader and the same texture for all of them
* If they are supposed to look very different, use your texture !
* If you can avoid sorting, and it still doesn’t look *too *bad, consider yourself lucky.

# Reference #

[简明教程，适合入门](http://open.gl/)

[入门教程](http://duriansoftware.com/joe/An-intro-to-modern-OpenGL.-Chapter-4:-Rendering-a-Dynamic-3D-Scene-with-Phong-Shading.html)

[有很多的教程和练习](http://en.wikibooks.org/wiki/OpenGL_Programming)

[3D Graphics with OpenGL Basic Theory](http://www.ntu.edu.sg/home/ehchua/programming/opengl/cg_basicstheory.html)