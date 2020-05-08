# Matrix transform
## 列空间
![MatrixTimesVector](/uploads/af1a7401390e44d60ba0f549104ca653/MatrixTimesVector.PNG)
![MatrixDotProductsWithRows](/uploads/0c9345377aa57c0979d76addc8c5b60d/MatrixDotProductsWithRows.PNG)
Those dot products are the same as column combination.
The new way is to work with Ax a column at a time. **Linear combinations are the key to
linear algebra, and the output Ax is a linear combination of the columns of A**.
![CoordinateTransform](/uploads/846b34216b5dde7583f005fb0b5b6d90/CoordinateTransform.PNG)
These special points simply select the column vectors on M. What does this mean?
**If M is applied to transform a model, then each column of M indicates precisely
how each coordinate axis is changed**. **matrix columns indicate how the coordinate axes are transformed by the matrix**.

## Shear
* Shear along the x direction: `(x,y)->(x+y, y)`
* Shear alone the y direction: `(x,y)->(x,x+y)`
* 3D shear matrices

![3Dshear](/uploads/68899be81481ccc4151d7aaca70fcb03/3Dshear.PNG)

## Look at transformation
![LookingAtTransformation](/uploads/2c25b99043bdc802c5e1d3eab49b440b/LookingAtTransformation.PNG)

## Orthogonal Transformation 正交变换
在线性代数中，正交变换是线性变换的一种，它从实内积空间V映射到V自身，且保证变换前后内积不变。
因为向量的模长与夹角都是用内积定义的，所以正交变换前后一对向量各自的**模长和它们的夹角都不变**。特别地，标准正交基经正交变换后仍为标准正交基。

在有限维空间中，正交变换在标准正交基下的矩阵表示为正交矩阵，其所有行和所有列也都各自构成V的一组标准正交基。因为正交矩阵的行列式**只可能为+1或−1，故正交变换的行列式为+1或−1。行列式为+1和−1的正交变换分别称为第一类的（对应旋转变换）和第二类的（对应瑕旋转变换）**。可见，欧几里得空间中的正交变换只包含**旋转、反射及它们的组合（即瑕旋转）**。反射也是瑕旋转的一种，它将物体关于反射轴左右对换，就好比镜中的像。
正交变换的逆变换也是正交变换，后者的矩阵表示是前者矩阵表示的逆。

正交矩阵是一个方块矩阵Q，其元素为实数，而且行与列皆为正交的单位向量，使得该矩阵的转置矩阵为其逆矩阵：
![](https://wikimedia.org/api/rest_v1/media/math/render/svg/c3a0b82f5f730c9397314ec6f8632ccb25a5de0a)
* 作为一个线性映射（变换矩阵），正交矩阵保持距离不变，所以它是一个保距映射，具体例子为旋转与镜射。
* 行列式值为+1的正交矩阵，称为特殊正交矩阵，它是一个旋转矩阵。
* 行列式值为-1的正交矩阵，称为瑕旋转矩阵。瑕旋转是旋转加上镜射。镜射也是一种瑕旋转。

## Translation and rotation in one matrix
![TranslationAndRotation](/uploads/e381bbb261424c3cad8ad82932e7c08e/TranslationAndRotation.PNG)
Inverse translation and rotation
![InverseTranslationAndRotation](/uploads/054df876ca85878430932780f35a21f1/InverseTranslationAndRotation.PNG)
Generally inverse transform
![InverseTransform](/uploads/b56ff92fe58b8134253b0d6ec734c950/InverseTransform.PNG)

## [Perspective Projection](PerspectiveProjection)


# clip space
裁剪发生在透视变换过程中。
Clip space is where the space points are in after the point transformation by the projection matrix, but before the normalisation by w.

Clipping happens somewhere when the points are being transformed by the projection matrix. **Not before, nor after**. So in essence, the projection matrix is used indirectly to "interleave" a process called clipping that is important in rendering.
![ClippingPipeline](/uploads/ba9bdebea89c5b5645a9e9a078777642/ClippingPipeline.PNG)

# Map the C matrix to the GLSL 
In C, an OpenGL 4×4 matrix is a 16-float array:
`float c_matrix[16];`

In GLSL the same matrix is:
`mat4 glsl_matrix;`

Let’s see how to map the C matrix to the GLSL one and vice-versa. Matrices in OpenGL are column-major. The c_matrix[] can be represented by:
```
0  4  8  12
1  5  9  13
2  6 10 14
3  7 11  15
```
The first column is made up of entries 0, 1, 2 and 3. The second column is 4, 5, 6, 7 and so on.

In C, the first entry of the first column is:
`c_matrix[0];`

While the second entry of the third column is:
`c_matrix[9];`

Now in GLSL. The first entry of the first column is:
`glsl_matrix[0][0];`

The second entry of the third column is:
`glsl_matrix[2][1];`

A mat4 can be seen as four vec4 vectors:
```
vec4 c0 = glsl_matrix[0].xyzw;
vec4 c1 = glsl_matrix[1].xyzw;
vec4 c2 = glsl_matrix[2].xyzw;
vec4 c3 = glsl_matrix[3].xyzw;
```
The first entry of the first column is now:
`glsl_matrix[0].x;`

And the second entry of the third column is:
`glsl_matrix[2].y;`

transfer c matrix to GPU
```
glUniformMatrix4fv(transformLoc, 1, GL_FALSE, glm::value_ptr(trans));
```
glUniform function with Matrix4fv as its postfix. The first argument should be familiar by now which is the uniform's location.     
The second argument tells OpenGL how many matrices we'd like to send, which is 1.     
The third argument asks us if we want to **  transpose our matrix, that is to swap the columns and rows **. OpenGL developers often use an internal matrix layout called column-major ordering which is the default matrix layout in GLM so there is no need to transpose the matrices; we can keep it at GL_FALSE.     
The last parameter is the actual matrix data, but GLM stores their matrices not in the exact way that OpenGL likes to receive them so we first transform them with GLM's built-in function value_ptr.

* multiplying a vector from the left to a matrix corresponds to multiplying it from the right to the transposed matrix:
```
vec2 v = vec2(10., 20.);
mat2 m = mat2(1., 2.,  3., 4.);
vec2 w = v * m; // = vec2(1. * 10. + 2. * 20., 3. * 10. + 4. * 20.)
```
Since there is no built-in function to compute a transposed matrix, this technique is extremely useful: whenever a vector should be multiplied with a transposed matrix, one can just multiply it from the left to the original matrix. 

# matrix imple
```
#ifndef MATRIX_H
#define MATRIX_H
#ifndef PI
#define PI 3.141592653f
#endif
#include <math.h>

struct vec2
{
    float x;
    float y;

    vec2() : x(0.0f), y(0.0f) { }
    vec2(float X, float Y) : x(X), y(Y){ }
    explicit vec2(float S) : x(S), y(S) { }
    vec2 operator + (const vec2 &rhs) const { return vec2(x + rhs.x, y + rhs.y); }
    vec2 operator * (const vec2 &rhs) const { return vec2(x * rhs.x, y * rhs.y); }
    vec2 operator - (const vec2 &rhs) const { return vec2(x - rhs.x, y - rhs.y); }
    vec2 operator * (const float s)  const  { return vec2(x * s, y * s); }
    vec2 operator / (const float s)  const  { return vec2(x / s, y / s); }

    vec2 &operator *= (const float s)   { *this = *this * s; return *this; }
    vec2 &operator += (const vec2 &rhs) { *this = *this + rhs; return *this; }
    vec2 &operator *= (const vec2 &rhs) { *this = *this * rhs; return *this; }
    vec2 &operator -= (const vec2 &rhs) { *this = *this - rhs; return *this; }

    float &operator [] (unsigned int i)             { return (&x)[i]; }
    const float &operator [] (unsigned int i) const { return (&x)[i]; }
};

struct vec3
{
    float x;
    float y;
    float z;

    vec3() : x(0.0f), y(0.0f), z(0.0f) { }
    vec3(float X, float Y, float Z) : x(X), y(Y), z(Z) { }
    explicit vec3(float S) : x(S), y(S), z(S) { }
    vec3 operator - () const { return vec3(-x, -y, -z); }
    vec3 operator + (const vec3 &rhs) const { return vec3(x + rhs.x, y + rhs.y, z + rhs.z); }
    vec3 operator * (const vec3 &rhs) const { return vec3(x * rhs.x, y * rhs.y, z * rhs.z); }
    vec3 operator - (const vec3 &rhs) const { return vec3(x - rhs.x, y - rhs.y, z - rhs.z); }
    vec3 operator * (const float s)  const  { return vec3(x * s, y * s, z * s); }
    vec3 operator / (const float s)  const  { return vec3(x / s, y / s, z / s); }

    vec3 &operator += (const vec3 &rhs) { *this = *this + rhs; return *this; }
    vec3 &operator *= (const vec3 &rhs) { *this = *this * rhs; return *this; }
    vec3 &operator -= (const vec3 &rhs) { *this = *this - rhs; return *this; }

    float &operator [] (unsigned int i)             { return (&x)[i]; }
    const float &operator [] (unsigned int i) const { return (&x)[i]; }
};

struct vec4
{
    float x;
    float y;
    float z;
    float w;

    vec4() : x(0.0f), y(0.0f), z(0.0f), w(0.0f) { }
    vec4(vec3 V, float W) : x(V.x), y(V.y), z(V.z), w(W) { }
    vec4(float X, float Y, float Z, float W) : x(X), y(Y), z(Z), w(W) { }
    explicit vec4(float S) : x(S), y(S), z(S), w(S) { }
    vec4 operator - () const { return vec4(-x, -y, -z, -w); }
    vec4 operator + (const vec4 &rhs) const { return vec4(x + rhs.x, y + rhs.y, z + rhs.z, w + rhs.w); }
    vec4 operator * (const vec4 &rhs) const { return vec4(x * rhs.x, y * rhs.y, z * rhs.z, w * rhs.w); }
    vec4 operator - (const vec4 &rhs) const { return vec4(x - rhs.x, y - rhs.y, z - rhs.z, w - rhs.w); }
    vec4 operator * (const float s)  const  { return vec4(x * s, y * s, z * s, w * s); }
    vec4 operator / (const float s)  const  { return vec4(x / s, y / s, z / s, w / s); }

    vec4 &operator *= (const float s)   { *this = *this * s; return *this; }
    vec4 &operator += (const vec4 &rhs) { *this = *this + rhs; return *this; }
    vec4 &operator *= (const vec4 &rhs) { *this = *this * rhs; return *this; }
    vec4 &operator -= (const vec4 &rhs) { *this = *this - rhs; return *this; }

    float &operator [] (unsigned int i)             { return (&x)[i]; }
    const float &operator [] (unsigned int i) const { return (&x)[i]; }

    vec3 xyz() const { return vec3(x, y, z); }
};

struct mat4
{
    vec4 x, y, z, w; // columns

    mat4() { }
    explicit mat4(float s) : x(0.0f), y(0.0f), z(0.0f), w(0.0f)
    {
        x.x = s;
        y.y = s;
        z.z = s;
        w.w = s;
    }

    mat4 operator * (const mat4 &rhs)
    {
        mat4 m;
        for (int lrow = 0; lrow < 4; ++lrow)
        {
            for (int rcol = 0; rcol < 4; ++rcol)
            {
                m[rcol][lrow] = 0.0f;
                for (int k = 0; k < 4; ++k)
                {
                    m[rcol][lrow] += (*this)[k][lrow] * rhs[rcol][k];
                }
            }
        }
        return m;
    }

    mat4 operator * (const float s)
    {
        mat4 m = *this;
        m.x *= s;
        m.y *= s;
        m.z *= s;
        m.w *= s;
        return m;
    }

    vec4 operator * (const vec4 &rhs)
    {
        return x * rhs.x + y * rhs.y + z * rhs.z + w * rhs.w;
    }

    vec4 &operator [] (unsigned int i) { return (&x)[i]; }
    const vec4 &operator [] (unsigned int i) const { return (&x)[i]; }
    const float *value_ptr() const { return &(x[0]); }
    float *value_ptr() { return &(x[0]); }
};

static vec3 normalize(const vec3 &v)
{
    return v / sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
}

static mat4 transpose(const mat4 &m)
{
    vec4 a = m.x;
    vec4 b = m.y;
    vec4 c = m.z;
    vec4 d = m.w;
    mat4 result;
    result.x = vec4(a.x, b.x, c.x, d.x);
    result.y = vec4(a.y, b.y, c.y, d.y);
    result.z = vec4(a.z, b.z, c.z, d.z);
    result.w = vec4(a.w, b.w, c.w, d.w);
    return result;
}

static mat4 perspective(float fovy, float aspect, float z_near, float z_far)
{
    mat4 m(1.0f);
    float invtf = 1.0f / tan(fovy * 0.5f);
    m[0].x = invtf / aspect;
    m[1].y = invtf;
    m[2].z = -(z_far + z_near) / (z_far - z_near);
    m[2].w = -1.0f;
    m[3].z = (-2.0f * z_far * z_near) / (z_far - z_near);
    m[3].w = 0.0f;
    return m;
}

static mat4 orthographic(float left, float right, float bottom, float top, float z_near, float z_far)
{
    mat4 m(1.0f);
    m[0].x = 2.0f / (right - left);
    m[3].x = -(right + left) / (right - left);
    m[1].y = 2.0f / (top - bottom);
    m[3].y = -(top + bottom) / (top - bottom);
    m[2].z = -2.0f / (z_far - z_near);
    m[3].z = -(z_far + z_near) / (z_far - z_near);
    return m;
}

static mat4 rotateX(float rad)
{
    float co = cosf(rad); float si = sinf(rad);
    mat4 m(1.0f);
    m[1][1] = co; m[1][2] = -si; m[2][1] = si; m[2][2] = co;
    return m;
}

static mat4 rotateY(float rad)
{
    float co = cosf(rad); float si = sinf(rad);
    mat4 m(1.0f);
    m[0][0] = co; m[0][2] = si; m[2][0] = -si; m[2][2] = co;
    return m;
}

static mat4 rotateZ(float rad)
{
    float co = cosf(rad); float si = sinf(rad);
    mat4 m(1.0f);
    m[0][0] = co; m[1][0] = -si; m[0][1] = si; m[1][1] = co;
    return m;
}

static mat4 translate(float x, float y, float z)
{
    mat4 m(1.0f);
    m[3][0] = x; m[3][1] = y; m[3][2] = z; m[3][3] = 1.0f;
    return m;
}

static mat4 translate(const vec3 &v)
{
    mat4 m(1.0f);
    m[3][0] = v.x; m[3][1] = v.y; m[3][2] = v.z;
    return m;
}

static mat4 scale(float x, float y, float z)
{
    mat4 m(1.0f);
    m[0][0] = x; m[1][1] = y; m[2][2] = z;
    return m;
}

static mat4 scale(float s)
{
    return scale(s, s, s);
}

#endif
```