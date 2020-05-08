# Matrix
matrix defines in a concise way, a combination of linear transformations that can be applied to points and vectors (scale, rotation, translation).
## Matrix Multiplication
![Matrix Multiplication](http://www.scratchapixel.com/images/upload/geometry/matrixmult.png?)

a matrix to transform A to C can be obtained by multiplying a matrix M1 that transform A to B with a matrix M2 that transform point B to C. The multiplication of any combination of matrix that transform in successive steps A to C will give matrix M3.

What's important to understand now is that a matrix multiplication is a way of combining in one matrix the effect of two other matrices. In other words, the transformation that each matrix M1 and M2 would operate on a point or a vector can be combined in one single matrix M3. 

## Orthogonal Matrices
Orthogonal matrices have a few interesting properties but maybe the most useful one in Computer Graphics, is that the transpose of an orthogonal matrix is equal to its inverse. 

orthogonal matrix which inverse can easily be obtained from computing its transpose. An orthogonal matrix is a square matrix with real entries whose columns and rows are orthogonal unit vectors. 

## Row Major vs Column Major Vector

## Matrix Transpose
Transposing matrices can be useful when you want to convert matrices from a 3D application using row-major matrices to another using a column-major convention (and vice versa).


## Matrix inversion
Matrix inversion is an important process in 3D. We know that we can use point- or vector-matrix multiplication to convert points and vectors but it is some times useful to be able to move the transformed points or vectors back into the coordinate system in which they were originally defined into. It is often necessary for instance, to transform the ray direction and origin in object space to test for a primitive-ray intersection. If there is an intersection the resulting hit point is in object space and needs to be converted back into world space to be usable.

# quaternions