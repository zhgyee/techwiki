# GPU Architecture
![8473.mali-top-level](/uploads/d55a8f1385c41ad9b7811e2ebddb66a8/8473.mali-top-level.png)
## Biling/Tiling Architecture
![QcomGPUBilingArchitecture](/img/QcomGPUBilingArchitecture.PNG)
Both the Snapdragon Adreno and ARM Mali GPUs found in Gear VR-supported phones use 
a tiled rendering architecture. Mali uses small, fixed-size tiles, and Adreno uses larger, 
variable-sized “bins,” but the performance characteristics are similar. The idea is that, 
instead of drawing triangles one at a time directly to a color/depth buffer in main memory, 
the triangles are grouped so that all the triangles in a small area can be drawn at once, 
using a tiny on-chip color buffer and depth buffer. If things go right, the traffic to main 
memory is just linear writes of the color buffer, the depth buffer doesn’t ever actually exist in main memory, 
and both power and performance are saved. However, for this to work, you have to do all your drawing to a surface in one batch.

The driver will skip that read if you’ve done a glClear() that covers the entire buffer. Simple apps often do that, 
but on most platforms it’s become a standard optimization for developers to skip clearing the color buffer, 
because every reasonable app does actually cover every pixel with drawing. On mobile, this is a de-optimization! 
The clear will always be faster than the forced read from main memory. The even-better solution is to use glInvalidateFramebuffer(), 
which does nothing but tell the driver that it can safely skip the read, even if you don’t clear.

绘制开始前，为了避免每次绘制时从主存加载到显存，要使用glClear和GlInvalidate指示驱动不需要加载之前绘制的内容，移动端不能出现GMEM load操作。

绘制结束前，需要无效depth buffer

should also do a glInvalidateFramebuffer() on your depth buffer after you’ve finished rendering but before flushing. 
This tells the driver that you promise not to use the depth buffer again, so it doesn’t have to write it out to memory along with the color buffer.

On Adreno, if you’re using glInvalidateFramebuffer() and you can noclip outside of your world, 
the leftover garbage data in the areas where nothing is drawn let you see the actual bin layout onscreen. On Mali, invalidates are equivalent to clears.

A less common historical optimization was to also avoid clearing the depth buffer 
by halving your depth precision and switching the depth range and test sense each frame. 
Don’t do that now—it’ll trigger the bad reads on mobile, but it’ll also screw up the various fast-Z optimizations on desktop GPUs.

# GPU Render model
## The CPU-GPU rendering pipeline

* glDraw function — commonly called a draw call 
* eglSwapBuffers -— to trigger the actual drawing operation

The logical rendering pipeline for Mali is therefore a three-stage pipeline of: 
* CPU processing, 
* geometry processing, and 
* fragment processing stages.

Pipeline Throttling

* CPU going idle once per frame as soon as “N” is reached, blocking inside an EGL or OpenGL ES API function until the display consumes a pending buffer, freeing up one for new rendering operations.
* This same scheme also limits the pipeline buffering if the graphics stack is running faster than the display refresh rate; 

![8863.gles-mali-vsync](/uploads/70dad17fc510b32ac2df0ae9eb4c392f/8863.gles-mali-vsync.png)

[The Mali GPU: An Abstract Machine, Part 1 - Frame Pipelining](https://community.arm.com/groups/arm-mali-graphics/blog/2014/02/03/the-mali-gpu-an-abstract-machine-part-1)
## Tile-based rendering
Mali uses a distinct two-pass rendering algorithm for each render target. It first executes all of the geometry processing, and then executes all of the fragment processing. During the geometry processing stage, Mali GPUs break up the screen into small 16x16 pixel tiles and construct a list of which rendering primitives are present in each tile.
```
    foreach( tile )  
         foreach( primitive in tile )  
              foreach( fragment in primitive in tile )  
                    render fragment  
```
![6646.blogentry-107443-038928000+1345199199_thumb](/uploads/e1bc5d6193217153e53af5ebf09a11d0/6646.blogentry-107443-038928000+1345199199_thumb.png)

## Shader core architecture
### The Tripipe
* arithmetic operations
* memory load/store and varying access
* texture access

![1440.mali-top-core](/uploads/213ed5c25b630d30438854613e240d61/1440.mali-top-core.png)
**There is one load/store and one texture pipe per shader core**, but the number of arithmetic pipelines can vary depending on which GPU you are using; most silicon shipping today will have two arithmetic pipelines, but GPU variants with up to four pipelines are also available.

### Arithmetic Pipeline
The arithmetic pipeline (A-pipe) is a SIMD (single instruction multiple data) vector processing engine, with arithmetic units which operate on 128-bit quad-word registers.

For example, the Mali-T760 with 16 cores is rated at 326 FP32 GFLOPS at 600MHz. This gives a total of 34 FP32 FLOPS per clock cycle for this shader core; it has two pipelines, so that's 17 FP32 FLOPS per pipeline per clock cycle. The available performance in terms of operations will increase for FP16/int16/int8 and decrease for FP64/int64 data types.
### Texture Pipeline
The texture pipeline (T-pipe) is responsible for all memory access to do with textures. The texture pipeline can return one bilinear filtered texel per clock; trilinear filtering requires us to load samples from two different mipmaps in memory, so requires a second clock cycle to complete.
### Load/Store Pipeline
The load/store pipeline (LS-pipe) is responsible for all memory accesses which are not related to texturing.  For graphics workloads this ** means reading attributes and writing varyings during vertex shading, and reading varyings during fragment shading**. In general every instruction is a single memory access operation, although like the arithmetic pipeline they are vector operations and so could load an entire "highp" vec4 varying in a single instruction.
# GPU Memory System
* Two 16KB L1 data caches per shader core; one for **texture access **and one for **generic memory access**.
* A single logical L2 which is shared by **all of the shader cores**. The size of this is variable and can be **configured** by the silicon integrator, but is typically between 32 and 64 KB per instantiated shader core.
* Both cache levels use 64 byte cache lines.

# GPU Preemption
Fine-grained GPU preemption make techniques like single buffered strip rendering or asynchronous time warping possible. It helps in balancing the creation of rich content and VR post-processing even at times when the CPU or GPU can’t keep up with its tasks in a timely fashion. Obviously there might be other use cases for GPU preemption and developers are free to make use of the EGL_IMG_context_priority extension for their own applications. VR being such a demanding task for a portable device, developers should also keep an eye on the CPU scheduling and make use of all the profiling tools available.

In our VR use case we obviously choose **EGL_CONTEXT_PRIORITY_HIGH_IMG **for the post-processing thread and     
**EGL_CONTEXT_PRIORITY_MEDIUM_IMG **for the content render (which is also the default).

# GPU metrics
## Pixel Rate
Pixel rate is the maximum amount of pixels the GPU could possibly write to the local memory in one second, measured in millions of pixels per second. The actual pixel output rate also depends on quite a few other factors, most notably the memory bandwidth - the lower the memory bandwidth is, the lower the ability to get to the maximum fill rate.

The is calculated by multiplying the number of ROPs (Raster Operations Pipelines - aka Render Output Units) by the the core clock speed.

Render Output Units : The pixel pipelines take pixel and texel information and process it, via specific matrix and vector operations, into a final pixel or depth value. The ROPs perform the transactions between the relevant buffers in the local memory.

Importance : **Higher the pixel rate, higher is the screen resolution of the GPU**.

## Texel Rate
A texture element is the fundamental unit of texture space (a tile of 3D object surface).

Texel rate is the maximum number of texture map elements (texels) that can be processed per second. It is measured in millions of texels in one second

This is calculated by multiplying the total number of texture units by the core speed of the chip.

Texture Mapping Units : Textures need to be addressed and filtered. This job is done by TMUs that work in conjunction with pixel and vertex shader units. It is the TMU's job to apply texture operations to pixels.

Importance : **Higher the texel rate, faster the game renders displays demanding games fluently**.

* A pixel is the fundamental unit of screen space.
* A texel, or texture element (also texture pixel) is the fundamental unit of texture space.

## GFLOPS

Floating point operations per second (FLOPS) are increasingly becoming a critical parameter for mobile GPUs when it comes to graphics and compute performance. The FLOPS metric indicates the number crunching ability of a graphics processor and can be compared to the million instructions per second (MIPS) that a CPU can deliver.

FLOPS determine ALU shader complexity level and usually impact several elements related to rendering a scene: the complexity of animation and lighting, the complexity of pixel shading, image quality and user experience.

## Triangles Per Second
三角形输出率：单位是兆/秒，三角形输出率越高，输出率越大，在大型3D应用中越流畅。
三角形输出率主要负责描绘图形，也就是建立图形的模形；像素填充率主要负责把绘出的图形填充颜色。
三角形生成率在目前的安卓应用中并不重要，我们目前还没有看到哪个游戏或UI的帧率被限制在三角形生成率，即使是在275MHZ 30M tri/s的参考平台。尤其在分辨率不断提高，从WVGA到QHD到720P、1080P已成为主流，主要需要的是像素处理能力的提高，而非三角形(顶点)处理的能力，因为行动游戏设计的趋势是用每个像素点上的效果(用SHADER来做)来产生场景的”复杂度”，过多的三角形，带寛的需求在行动平台上目前是无法满足的。

Todays graphics APIs don't really care how many triangles you use(triangle data are stored in buffers on the GPU and the API only sends a buffer id to the GPU, it doesn't matter if it is 1 triangle or 1 billion triangles from the APIs point of view). (The APIs care about things like draw calls, state changes, etc).
 
a modern GPU can handle several billion triangles per second in theory. in practice a few hundred million per second shouldn't be a problem in the normal case.

## draw call
桌面渲染程序中一帧超过1000个draw就会让单个CPU核运行非常吃力。这种情况在移动平台会更加常见，因为移动CPU的性能比桌面CPU更差，因此现在的移动游戏中通常一个场景也就两三百个draw call

Draw calls aren't necessarily expensive. In older versions of Direct3D, many calls required a context switch, which was expensive, but this isn't true in newer versions.

The main reason to make fewer draw calls is that graphics hardware can transform and render triangles much faster than you can submit them. If you submit few triangles with each call, you will be completely bound by the CPU and the GPU will be mostly idle. The CPU won't be able to feed the GPU fast enough.

Making a single draw call with two triangles is cheap, but if you submit too little data with each call, you won't have enough CPU time to submit as much geometry to the GPU as you could have.

There are some real costs with making draw calls, it requires setting up a bunch of state (which set of vertices to use, what shader to use and so on), and state changes have a cost both on the hardware side (updating a bunch of registers) and on the driver side (validating and translating your calls that set state).

But the main cost of draw calls only apply if each call submits too little data, since this will cause you to be CPU-bound, and stop you from utilizing the hardware fully.

## GPU Limits
 
Based on this simple model it is possible to outline some of the fundamental properties underpinning the GPU performance.
 
* The GPU can issue one vertex per shader core per clock
* The GPU can issue one fragment per shader core per clock
* The GPU can retire one pixel per shader core per clock
* We can issue one instruction per pipe per clock, so for a typical shader core we can issue four instructions in parallel if we have them available to run
* We can achieve 17 FP32 operations per A-pipe
* One vector load, one vector store, or one vector varying per LS-pipe
* One bilinear filtered texel per T-pipe
* The GPU will typically have 32-bits of DDR access (read and write) per core per clock [configurable]

If we scale this to a Mali-T760 MP8 running at 600MHz we can calculate the theoretical peak performance as:
```
Fillrate:
  8 pixels per clock = 4.8 GPix/s
  That's 2314 complete 1080p frames per second!
Texture rate:
  8 bilinear texels per clock = 4.8 GTex/s
  That's 38 bilinear filtered texture lookups per pixel for 1080p @ 60 FPS!
Arithmetic rate:
  17 FP32 FLOPS per pipe per core = 163 FP32 GFLOPS
  That's 1311 FLOPS per pixel for 1080p @ 60 FPS!
Bandwidth:
  256-bits of memory access per clock = 19.2GB/s read and write bandwidth1.
  That's 154 bytes per pixel for 1080p @ 60 FPS!
```
# GPU benchmark
## 3DMARK

* 1.VR安装3DMARK.apk后 → 
* 2.VR连接PC在cmd中输入：adb shell am start -n com.futuremark.dmandroid.application/com.futuremark.dmandroid.application.activity.SplashPageActivity运行 → 
* 3.VR连接Total Control操作测试

## GPUbench3D

* 1.VR安装GPUbench3D.apk后 → 
* 2.VR连接PC在cmd中输入：adb shell am start -n com.kortenoeverdev.GPUbench/com.unity3d.player.UnityPlayerProxyActivity运行 → 
* 3.VR连接Total Control操作测试

# GPU perf
## exynos
```
cat /sys/devices/platform/13900000.mali/clock
cat /sys/devices/platform/13900000.mali/utilization
```
## qcom
```
cat /sys/class/kgsl/kgsl-3d0/gpuclk
cat /sys/class/kgsl/kgsl-3d0/devfreq/gpu_load
```

[ref](https://community.arm.com/groups/arm-mali-graphics/blog/2014/03/12/the-mali-gpu-an-abstract-machine-part-3--the-shader-core)

