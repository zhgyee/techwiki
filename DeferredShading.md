# forward shding 缺点
* 场景复杂时不同深度上像素渲染存在浪费，最终只用到最前面的像素，通过排序法可以解决，但不是所有场景都能解决
* 多光源时，每个像素都要计算光照

# 原理
* The key point behind deferred shading is the decoupling of the geometry calculations (position and normal transformations) and the lighting calculations.
* In the first pass we run the usual VS but instead of sending the processed attributes into the FS for lighting calculations we forward them into what is known as the G Buffer. This is a logical grouping of several 2D textures and we have a texture per vertex attribute. We seperate the attributes and write them into the different textures all at once using a capability of OpenGL called Multiple Render Targets (MRT). 
* In the second pass (known as the Lighting Pass) we go over the G buffer pixel by pixel, sample all the pixel attributes from the different textures and do the lighting calculations in pretty much the same way that we are used to.
* How do we traverse the G buffer pixel by pixel? The simplest method is to render a screen space quad. But there is a better way. 

[ref](http://ogldev.atspace.co.uk/www/tutorial35/tutorial35.html)