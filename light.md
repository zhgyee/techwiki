# Directional lights
```
// Cosine of the angle between the normal and the light direction,
// clamped above 0
//  - light is at the vertical of the triangle -> 1
//  - light is perpendicular to the triangle -> 0
//  - light is behind the triangle -> 0
float cosTheta = clamp( dot( n,l ), 0,1 );

color = LightColor * cosTheta;
```
cosTheta depends on n and l. We can express them in any space provided it’s the same for both. We choose the camera space because it’s easy to compute the light’s position in this space :
```
// Normal of the computed fragment, in camera space
 vec3 n = normalize( Normal_cameraspace );
 // Direction of the light (from the fragment to the light)
 vec3 l = normalize( LightDirection_cameraspace );
```
# Diffuse reflection漫射
```
color = MaterialDiffuseColor * LightColor * cosTheta;
```
MaterialDiffuseColor is simply fetched from the texture.

# Point lights
For a directional light, we just stored a vector to that light, since that
vector is the same for all points in a scene. For a point light, we’ll store
the position instead, and we’ll use that position to calculate a vector to
the point light for each point in the scene.

With such a light, the luminous flux that our surface will receive will depend on its distance to the light source: the further away, the less light. In fact, the amount of light will diminish with the square of the distance 
```
color = MaterialDiffuseColor * LightColor * cosTheta / (distance*distance);
```
# Control the power of the light
This could be encoded into LightColor (and we will in a later tutorial), but for now let’s just have a color (e.g. white) and a power (e.g. 60 Watts).    
LightColor and LightPower are set in the shader through GLSL uniforms.
```
color = MaterialDiffuseColor * LightColor * LightPower * cosTheta / (distance*distance);
```
# Ambient light 环境光
```
vec3 MaterialAmbientColor = vec3(0.1,0.1,0.1) * MaterialDiffuseColor;
color =
 // Ambient : simulates indirect lighting
 MaterialAmbientColor +
 // Diffuse : "color" of the object
 MaterialDiffuseColor * LightColor * LightPower * cosTheta / (distance*distance) ;
```
# Specular reflection 反射
```
// Eye vector (towards the camera)
vec3 E = normalize(EyeDirection_cameraspace);
// Direction in which the triangle reflects the light
vec3 R = reflect(-l,n);
// Cosine of the angle between the Eye vector and the Reflect vector,
// clamped to 0
//  - Looking into the reflection -> 1
//  - Looking elsewhere -> < 1
float cosAlpha = clamp( dot( E,R ), 0,1 );

color =
    // Ambient : simulates indirect lighting
    MaterialAmbientColor +
    // Diffuse : "color" of the object
    MaterialDiffuseColor * LightColor * LightPower * cosTheta / (distance*distance) ;
    // Specular : reflective highlight, like a mirror
    MaterialSpecularColor * LightColor * LightPower * pow(cosAlpha,5) / (distance*distance);
```
R is the direction in which the light reflects. E is the inverse direction of the eye (just like we did for “l”); If the angle between these two is little, it means we are looking straight into the reflection.

pow(cosAlpha,5) is used to control the width of the specular lobe. Increase 5 to get a thinner lobe.

# Spot lights

# ref
[opengl-tutoria](http://www.opengl-tutorial.org/beginners-tutorials/tutorial-8-basic-shading/)