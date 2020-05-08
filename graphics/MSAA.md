# MSAA_RESOLVE
EXT_multisampled_render_to_texture

OVR_multiview_multisampled_render_to_texture
```
    Some GPU architectures - such as tile-based renderers - are
    capable of performing multisampled rendering by storing
    multisample data in internal high-speed memory and downsampling the
    data when writing out to external memory after rendering has
    finished. Since per-sample data is never written out to external
    memory, this approach saves bandwidth and storage space. In this
    case multisample data gets discarded, however this is acceptable
    in most cases.

    The extension provides a new command, FramebufferTexture2DMultisampleEXT,
    which attaches a texture level to a framebuffer and enables
    multisampled rendering to that texture level.

    When the texture level is flushed or used as a source or destination
    for any operation other than drawing to it, an implicit resolve of
    multisampled color data may be performed. After such a resolve, the
    multisampled color data is discarded.
```
# MSAA_BLIT
通过glBindFramebuffer获取MSAA FBO 中的像素

# ref
[learnopengl-Anti Aliasing](https://learnopengl.com/Advanced-OpenGL/Anti-Aliasing)

[A QUICK OVERVIEW OF MSAA](https://mynameismjp.wordpress.com/2012/10/24/msaa-overview/)