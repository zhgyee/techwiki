# How do normals work?
A normal is vector that is perpendicular to a surface. We always use normals of unit length and they point to the outside of their surface, not to the inside.

Normals can be used to determine the angle at which a light ray hits a surface, if at all. The specifics of how it is used depends on the shader.

As a triangle is always flat, there shouldn't be a need to provide separate information about normals. However, by doing so we can cheat. In reality vertices don't have normals, triangles do. By attaching custom normals to vertices and interpolating between them across triangles, we can pretend that we have a smoothly curving surface instead of a bunch of flat triangles. 
This illusion is convincing, as long as you don't pay attention to the sharp silhouette of the mesh.

# Unity::mesh.RecalculateNormals();
The Mesh.RecalculateNormals method computes the normal of each vertex by figuring out which triangles connect with that vertex, 
determining the normals of those flat triangles, averaging them, and normalizing the result.

# Normal map & normal vector
Another way to add more apparent detail to a surface is to use a normal map. These maps contain normal vectors encoded as colors. 
Applying them to a surface will result in much more detailed light effects than could be created with vertex normals alone.
## tangent space & tangent vector
Normal maps are defined in tangent space. This is a 3D space that flows around the surface of an object. 
This approach allows us to apply the same normal map in different places and orientations.

The surface normal represents upward in this space, but which way is right? That's defined by the tangent. 
Ideally, the angle between these two vectors is 90°. The cross product of them yields the third direction needed to define 3D space. 
In reality the angle is often not 90° but the results are still good enough.

So a tangent is a 3D vector, but Unity actually uses a 4D vector. 
Its fourth component is always either −1 or 1, which is used to control the direction of the third tangent space dimension – 
either forward or backward. 
This facilitates mirroring of normal maps, which is often used in 3D models of things with bilateral symmetry, like people. 
The way Unity's shaders perform this calculation requires us to use −1.
## TBN matrix
There are basically two ways we can use a TBN matrix for normal mapping and we'll demonstrate both of them:

*We take a TBN matrix that transforms any vector from tangent to world space, give it to the fragment shader and transform the sampled normal from tangent space to world space using the TBN matrix; the normal is then in the same space as the other lighting variables.
*We take the inverse of the TBN matrix that transforms any vector from world space to tangent space and use this matrix to transform not the normal, 
but the other relevant lighting variables to tangent space; the normal is then again in the same space as the other lighting variables.
```
normal = texture(normalMap, fs_in.TexCoords).rgb;
normal = normalize(normal * 2.0 - 1.0);   
normal = normalize(fs_in.TBN * normal); 
```