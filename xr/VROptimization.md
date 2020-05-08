# Application side
* Discard unused buffers (eg. Depth) and clear/invalidate to avoid loads
* Use reasonable CPU/GPU workloads to make a thermally stable application
* Render occluding geometry to portions of eye buffer that aren’t visible
* Foveation used to reduce pixel load and bandwidth
* Could further increase foveation by placing text out of the periphery or in a separate non-foveated layer
* Use Multiview to reduce stereo rendering workloads
* Use late latching to reduce latency
* Use MSAA
* Use forward rendering algorithms (not deferred shading)
* Use short shaders
* Keep post processing effects to a minimum
* Reserve ~20% GPU performance (2+ ms) for the async reprojection operation

# GMEM Loads and Stores
* Also referred to as Unresolves / Resolves
* Moves memory from system memory to tile memory and back
* Avoid loads whenever possible
  * Clear or glInvalidateFramebuffer/glDiscardFramebufferEXT
  * Ensure all attachments are cleared, including depth + stencil
* Discard or Invalidate any surfaces you don’t need to Store
  * App can call discard/invalidate prior to flush
  * Discard depth/stencil if not used by async reprojection
  * Especially true if using the EXT_multisampled_render_to_texture extension which leaves depth buffers undefined
  * Snapdragon VR SDK: Use beginEye()/endEye()
