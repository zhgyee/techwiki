# 运算
* If the binary operators *, /, +, -, =, *=, /=, +=, -= are used between vectors of the same type, they just work component-wise
```
vec3 a = vec3(1.0, 2.0, 3.0);
vec3 b = vec3(0.1, 0.2, 0.3);
vec3 c = a + b; // = vec3(1.1, 2.2, 3.3)
vec3 d = a * b; // = vec3(0.1, 0.4, 0.9)
```
* For matrices, these operators also work component-wise, except for the *-operator, which represents a matrix-matrix product
```
mat2 a = mat2(1., 2.,  3., 4.);
mat2 b = mat2(10., 20.,  30., 40.);
mat2 c = a * b; // = mat2(
   // 1. * 10. + 3. * 20., 2. * 10. + 4. * 20., 
   // 1. * 30. + 3. * 40., 2. * 30. + 4. * 40.)
```
* For a component-wise matrix product, the built-in function `matrixCompMult` is provided.
```
TYPE matrixCompMult(TYPE a, TYPE b) // component-wise matrix product
```
* The *-operator can also be used to multiply a floating-point value (i.e. a scalar) to all components of a vector or matrix (from left or right):
```
vec3 a = vec3(1.0, 2.0, 3.0);
mat3 m = mat3(1.0);
float s = 10.0;
vec3 b = s * a; // vec3(10.0, 20.0, 30.0)
vec3 c = a * s; // vec3(10.0, 20.0, 30.0)
mat3 m2 = s * m; // = mat3(10.0)
mat3 m3 = m * s; // = mat3(10.0)
```
* Furthermore, the *-operator can be used for matrix-vector products of the corresponding dimension, e.g.:
```
vec2 v = vec2(10., 20.);
mat2 m = mat2(1., 2.,  3., 4.);
vec2 w = m * v; // = vec2(1. * 10. + 3. * 20., 2. * 10. + 4. * 20.)
```
* multiplying a vector from the left to a matrix corresponds to multiplying it from the right to the transposed matrix:
```
vec2 v = vec2(10., 20.);
mat2 m = mat2(1., 2.,  3., 4.);
vec2 w = v * m; // = vec2(1. * 10. + 2. * 20., 3. * 10. + 4. * 20.)
```
[see detail](https://en.wikibooks.org/wiki/GLSL_Programming/Vector_and_Matrix_Operations)

# Row Major vs Column Major Vector
when by convention we decide to express vectors or points in row-major order ([1x3]), we need to put the point on the left side of the multiplication and the [3x3] on the right inside of the multiplication sign. This is called in mathematics, a left or pre-multiplication. If you decide to write the vectors in column-major order instead ([3x1]), the [3x3] matrix needs to be of the left side of the multiplication and the vector or point on the right inside. This is called a right or post-multiplication.

[Row Major vs Column Major Vector](http://www.scratchapixel.com/lessons/mathematics-physics-for-computer-graphics/geometry/row-major-vs-column-major-vector)

# transposed matrix

```
vec2 v = vec2(10., 20.);
mat2 m = mat2(1., 2.,  3., 4.);
vec2 w = m * v; // = vec2(1. * 10. + 3. * 20., 2. * 10. + 4. * 20.)
```
If a vector is multiplied to a matrix from the left, the result corresponds to multiplying a row vector from the left to the matrix. This corresponds to multiplying a column vector to the transposed matrix from the right:

![transposed matrix](https://upload.wikimedia.org/math/5/8/5/585f38d8654b13b63e7c3cc8a92fbbe9.png)

Thus, multiplying a vector from the left to a matrix corresponds to multiplying it from the right to the transposed matrix:
```
vec2 v = vec2(10., 20.);
mat2 m = mat2(1., 2.,  3., 4.);
vec2 w = v * m; // = vec2(1. * 10. + 2. * 20., 3. * 10. + 4. * 20.)
```
Since there is no built-in function to compute a transposed matrix, this technique is extremely useful: whenever a vector should be multiplied with a transposed matrix, one can just multiply it from the left to the original matrix. Several applications of this technique are described in Section “Applying Matrix Transformations”.