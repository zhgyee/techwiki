# Camera Model
The projection of the points in the physical world into the camera is now summarized by the following simple form:
```math
\begin{aligned}
\vec{q}=M\cdot\vec{Q}  \text{ where,}\\
\vec{q}=\begin{pmatrix} x \\ y \\ w \end{pmatrix}, M=\begin{pmatrix} f_x & 0 & c_x \\ 0 & f_y & c_y \\ 0 & 0 & 1 \end{pmatrix} \text{ and }
 \vec{Q}=\begin{pmatrix} X \\ Y \\ Z \end{pmatrix}
\end{aligned}
```
Multiplying this out, you will find that w = Z and so, since the point $`\vec{q}`$ is in homogeneous coordinates, we can divide through by w (or Z)

# Rodrigues Transform
The Rodrigues form represents a rotation by a vector whose direction stands for the
axis of rotation and whose magnitude is the angle through which the object is rotated clockwise around the axis. That is, if the 3-vector $`w=[w_x w_y w_z]^T`$ represents an object rotation, the axis of rotation is given by $`\frac{w}{\|w\|}`$, and the angle $`\phi=\|w\|`$

see detail at https://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula

# Homography
In computer vision, we define planar homography as a projective mapping from one plane to another.
```math
\begin{aligned}
\vec{q} = s \cdot H \cdot \vec{Q}\\
\vec{q}=\begin{pmatrix} x \\ y \\ 1 \end{pmatrix} = s \cdot M \cdot \begin{pmatrix} \vec{r_1}, \vec{r_2}, \vec{t} \end{pmatrix} \cdot \begin{pmatrix} X \\Y \\1 \end{pmatrix}
\end{aligned}
```

## Direct Linear Transformation of estimated homographies
直接通过构建线程方程Ax=0的格式来求解Homography矩阵,为了解决全0解（泛化）问题，有两种解决方案：
* 将H的最后的一个元素设置为1，避免出现全0的情况
* singular-value decomposition - SVD，最分解后对角最小元素对应的向量。

## Non-linear refinement of estimated homographies

# vanishing points calibration
* 3 finite vanishing points: get f, u0, v0
* 2 finite and one infinite : u0,v0 as point on vf1 vf2 closest to image center, get f
* 2 infinite vanishing points : f cant be recovered u0, v0 is at the third vanishing point

see detail "illinois vision course lecture 3"

# The Jacobian function
In addition to the value function F(), the Levenberg-Marquart method requires
the Jacobian of the involved model functions.
## analytical calculation
通常使用matlab自动生成，但非常冗长和复杂。
## Numeric calculation.
It is also possible to estimate the partial derivatives
numerically by finite difference approximation in the form
```math
\frac{\partial f_i(x,p)}{\partial p_j} ~= \frac{f_i(x,p+ \delta_j \cdot e_j) - f_k(x,p)}{\delta}
```
![jacobi-numeric-calculation](/uploads/6c2575943817000025d098677ba70909/jacobi-numeric-calculation.PNG)



# reference
Zhang’s Camera Calibration Algorithm:In-Depth Tutorial and Implementation