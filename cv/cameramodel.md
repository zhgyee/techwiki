# Pin hole model
For most practical lens systems,we can model the lens as a "pinhole" from a classical pinhole camera。

带lens的pinhole model，在3D到2D转换时，需要带入焦距f,  $`x'=f \frac{X}{Z} \text{ and } y'=f \frac{Y}{Z}`$，而普通的pinhole的f=1

# Pixels, Radians, and Distances
![pix2rad](/uploads/83bd78f2c382687df91ca3f996098e23/pix2rad.jpg)

The figure above shows a geometric model of a camera system. Two rays of light, from opposite ends of an object, 
travel through a lens and strike two adjacent pixels of an image sensor. 
**For most practical lens systems,we can model the lens as a "pinhole" from a classical pinhole camera**. 
Let p be the "pitch" between pixels on the image sensor chip. 
On a Tam2 image sensor chip, this is 84 microns. 
Next let f denote the "focal length" of the lens. 
In our model this is the distance from the image sensor chip to the pinhole that models the lens. 
On a conventional camera lens, which is generally constructed with multiple lens elements, 
the focal length of that lens refers to the distance of such a "virtual pinhole" from the image sensor. 
For the small lens mounted onto the Tam2 sensors for some of the ArduEye boards, the effective value of f is about 0.9mm or 900 microns.

Let us now consider dimensions on the outside of the camera. Let r denote the "range" or the distance from the camera lens to an object being viewed. Let d denote the size of the object. Finally, let angle alpha denote the angular size of the object as viewed from the camera.
Using our first-order approximation, the above five variables follow this relationship:
alpha = (p/f) = (d/r)

Before we begin- first one assumption: I'm going to assume that all angles are "relatively small" so that a first order approximation can be used for trigonometric functions. For "small" angles of theta, we can use the first order approximation :    
**sin(theta)=theta and tan(theta)=theta**.    
sin(pi/180)~=pi/180=0.01744