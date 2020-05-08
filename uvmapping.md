# UV space
UV(W) coordinates are a normalized (0 to 1) 2-Dimensional coordinate system, where the origin (0,0) exists in the bottom left corner of the space. UV is in this case synonymous to XY, but since XY is used in the XYZ 3D space so we use UVW in the texture space to avoid confusion.

Note that there is a W which corresponds to the Z axis, but it won't be used in a Texture2D as it is 2D.

So with that said, think of this 0 to 1 space as 0% to 100% of the image. If your texture is 128x128 then having a coordinate of 1 in either the U or V would mean that that particular vertex will exist at the normalized bounds of our texture space.

Example: a vertex with a UV of .5,.5 will be in the exact center of the image.

This works for non-square as well. Example: an image of 512,128 and a vertex with a UV coordinate of .5,.5 will exist at 256,64 in our texture.

Now, you asked how a 4vert quad would look, in short it would look something like this:

top-left 0,1 top-right 1,1 bottom-left 0,0 bottom-right 1,0

Depending on how you've assembled your triangles will vary on what vertex is what, but follow those guidelines and you should be able to figure it out.

# Mapping a Globe onto the Sphere

We have a sphere in this code.  Wouldn't it be neat to map the world onto that sphere?  But, what would it take to do this?

First, let's enable the texture.  Add the following code to the Sphere function before the SphereFace calls.  Then, all a glDisable(GL_TEXTURE_2D) call after those calls.
```
glEnable(GL_TEXTURE_2D);
glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
glBindTexture(GL_TEXTURE_2D, m_worldmap.TexName());
```
A question you may have:  Why am I using the glTexEnvf when I didn't for the map on the cube?  I knew there was no other code between faces of the cube that might change GL_TEXTURE_ENV_MODE.  But, I don't know if it may have been changed elsewhere.  Also, should I just call sphere without ever calling cube, the parameter would never be set.

The interesting problem for the sphere is to determine the texture coordinates for each vertex.  One way to look at this problem is to use the surface normal as way to tell where we are on the face of the sphere.  If we consider this a vector from the inside of the sphere, we can easily compute the latitude and longitude on the surface of the globe.  These values correspond to point on the map.

Right after the call to glBegin(GL_TRIANGLES), add the following code:

// What's the texture coordinate for this normal?
```
tx1 = atan2(a[0], a[2]) / (2. * GR_PI) + 0.5;
ty1 = asin(a[1]) / GR_PI + .5;

glTexCoord2f(tx1, ty1);
```
So, what does this do?  a[0] and a[2] are the X and Z values of the normal.  If you look straight down onto the globe from the top, the vector made up of the X and Z values will tell you the longitude on the globe!  I use atan2 to convert that to an angle in radians.  This angle is between -PI and PI.  I divide by 2PI, so it's now between -.5 and .5.  Adding 0.5 makes it range from 0 to 1.  This is the X value in the texture map.  

Next, I compute the Y value in the texture map.  a[1] is the Y value of the normal.  If you consider a right triangle with a hypotenuse of length 1 (our normalized vector) and a rise of Y, we can compute the angle using asin.  This is the angle between the Y vector and the X/Z plane.  This gives us values from -PI / 2 to PI / 2.  (up to 90 degrees up or down).  ty1 then ranges from 0 to 1.  

Add lines like this for the other two vertices.  I suggest not reusing tx1 and ty1, since we'll need to change something in a moment.

Run this and spin the globe.  You may notice that there's part of the globe that's messed up.  Try to take a moment and figure out what it is.  Then, read the following answer.

The problem is that some triangles will map to both ends of the map.  After all, the right edge of the map meets the left edge.  Imagine a triangle hanging off one edge.  The problem is that the trig functions simply wrap the value around.  So, you end of with a triangle the has two vertices on one edge of the map and one on the other edge.  This causes all of the map between these points to be smashed into the image mapped onto the polygon. 

So, how do we fix this?  The easiest solution is to check for this problem.  Try this for the second vertex:
```
// The second vertex
tx = atan2(b[0], b[2]) / (2. * GR_PI) + 0.5;
ty = asin(b[1]) / GR_PI + .5;
if(tx < 0.75 && tx1 > 0.75)
tx += 1.0;
else if(tx > 0.75 && tx1 < 0.75)
tx -= 1.0;

glTexCoord2f(tx, ty);
```
Do the same for the third vertex (based on vector c, of course), and you should have a nicely mapped globe.

[ref](http://www.cse.msu.edu/~cse872/tutorial4.html)