# LOD
Depending on its distance from the camera, an object will be drawn with a lower or higher-poly mesh, or not drawn at all. 
For example, beyond a certain distance the grass or the flowers are never rendered. So this step calculates for each object if it will be rendered and at which LOD.
This step is processed by a compute shader.

# Defer Rendering
## Gbuffer
All the visible meshes are drawn one-by-one, but instead of calculating the shading immediately, 
the draw calls simply output some shading-related information into different buffers called **G-Buffer**. 
GTA V uses **MRT** so each draw call can output to 5 render targets at once.

Later, all these buffers are combined to calculate the final shading of each pixel. 
Hence the name **“deferred”** in opposition to **“forward”** for which each draw call calculates the final shading value of a pixel.
For this step, only the opaque objects are drawn, transparent meshes like glass need special treatment in a deferred pipeline and will be treated later.

All these render targets are LDR buffers (RGBA, 8 bits per channel) storing different information involved later in the calculation of the final shading value.
The buffers are:
* Diffuse map: 
it stores the “intrinsic color” of the mesh. It represents a property of the material, 
it is in theory not influenced by the lighting. But do you notice the white highlights on the car’s hood? 
Interestingly GTA V calculates the shading resulting from the sun directional light before outputting to the diffuse map.
The alpha channel contains special “blending” information (more on that later).
* Normal map: 
it stores the normal vector for each pixel (R, G, B). 
The alpha channel is also used although I am not certain in which way: it looks like a binary mask for certain plants close to the camera.
* Specular map: 
it contains information related to specular/reflections:
 * Red: specular intensity
 * Green: glossiness (smoothness)
 * Blue: fresnel intensity (usually constant for all the pixels belonging to the same material)
* Irradiance map: 
the Red channel seems to contain the irradiance each pixel receives from the sun (based on the pixel’s normal and position, and the sun shining direction). 
I am not 100% sure about the Green channel, but it looks like the irradiance from a second light source. Blue is the emissive property of the pixel (non-zero for neon, light bulbs). Most of the alpha channel is not used except for marking the pixels corresponding to the character’s skin or the vegetation.
* Depth-stencil buffer
 * Depth map: it stores the distance of each pixel from the camera. 
 * Stencil: it is used to identify the different meshes drawn, assigning the same ID to all the pixels of a certain category of meshes.