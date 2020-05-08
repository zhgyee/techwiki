#image model
![](http://www.scratchapixel.com/images/upload/introduction-to-ray-tracing/vantagepoint.png)    
we can visualize a picture as a cut made through a pyramid whose apex is located at the center of our eye and whose height is parallel to our line of sight.
#Perspective Projection
![](http://www.scratchapixel.com/images/upload/introduction-to-ray-tracing/projperspective.gif)     
projecting the four corners of the front face on the canvas
#backward ray-tracing
![](http://www.scratchapixel.com/images/upload/introduction-to-ray-tracing/tracefromeyetolight.gif)   
backward ray-tracing. We trace a ray from the eye to a point on the sphere, then a ray from that point to the light source.
#primary ray and shadow ray
![](http://www.scratchapixel.com/images/upload/introduction-to-ray-tracing/lightingshadow.gif)   
we shoot a primary ray through the center of the pixel to check for a possible object intersection. When we find one we then cast a shadow ray to find out if the point is illuminated or in shadow. the small sphere cast a shadow on the large sphere. The shadow ray intersects the small sphere before it gets to the light.
#ray-tracing render model
![](http://www.scratchapixel.com/images/upload/introduction-to-ray-tracing/pixelrender.gif)   
to render a frame, we shoot a primary ray for each pixel of the frame buffer

# reflection and refraction
![](http://www.scratchapixel.com/images/upload/introduction-to-ray-tracing/reflectionrefraction.gif)   
using optical laws to compute reflection and refraction rays

