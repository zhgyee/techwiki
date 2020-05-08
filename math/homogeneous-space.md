# 齐次坐标
If the homogeneous coordinates of a point are multiplied by a non-zero scalar then the resulting coordinates represent the same point. 
[see vikipedia](https://en.wikipedia.org/wiki/Homogeneous_coordinates)

![齐次性](https://wikimedia.org/api/rest_v1/media/math/render/svg/266351253e55f5471fa9526657e844362084d3a8)

* 点的齐次坐标为（x,y,z,1）
* 向量的齐次坐标为(x,y,z,0), 最后为0是为了避免平稳变换：This nullifies the effect of translation in the world matrix (the fourth column). The reason is that vectors cannot be moved like points. They can only be scaled or rotated

# 点与直线的齐次表示
* **像平面上的点在齐次空间中表示(x,y,1)为过投影中心的射线，点的坐标(x,y)为射线的方向。**
* **像平面上的直线在齐次空间中表示(a,b,c)为过投影中心的平面，平面的法向（a,b,c）为该直线的法向。**
* 直线l的方程ax+by+c=0 的矢量表示：$`l=(a,b,c)^T`$
* 直线l的切线为 $` (b, -a)^T `$，法线为 $`(a, b)^T`$ 
* 点$`x=(x,y)^T`$的齐次表示：$`x=(x,y,1)^T`$
* 点$`x=(x,y,1)^T`$在直线$`l=(a,b,c)^T`$上的充要条件是：$`x^T \cdot l=0`$
* 两条直线l和l'的交点$`x=l \times l' `$
* 过两点x和x'的直线$` l=x \times x' `$
* 点x到直线l垂直的距离 $` E=\lvert{x\cdot l}\rvert`$

# 理想点和无穷远线 Ideal points and the line at infinity
* ideal points(point at infinity) $` P_i = (x_1, x_2, 0)  `$, parallel to image plane
* ideal line $`l=(a,b,0)`$，parallel to image plane, Corresponds to a line in the image (finite coordinates)
* line at infinity $` I_\infty = (0, 0, 1) `$，所有的ideal points都在无穷远线上。
* The line at infinity can be thought of as the set of directions of lines in the plane. 无穷远线可以看做平面上所有直线的方向的集合。

# vanishing point
* 测量camera的高度。
* 测量物体高度。
* 计算camera内参和外参。
* 视觉欺骗。

# 对偶定理
To any theorem of 2-dimensional projective geometry
there corresponds a dual theorem, which may be derived by interchanging** the roles of points and lines** in the original theorem.

# Conics.
## 定义
* 非齐次方程 $` ax^2+bxy+cy^2+dx+ey+f=0 `$
* 齐次方程 $`ax_1^2+bx_1x_2+cx_2^2+dx_1x_3+ex_2x_3+fx_3^2 = 0`$
* 矩阵形式 $`x^TCx=0`$，其中$`C = \begin{vmatrix}  a & b/2 & d/2 \\ b/2 & c & e/2 \\ d/2 & e/2 & f \end{vmatrix}`$.

## Dual conics
The dual (or line) conic is also represented by a 3 × 3 matrix, which we denote as $`C^{\star}`$. The notation $`C^{\star}`$ indicates that $`C^{\star}`$ is the adjoint matrix of C. A line l tangent to the conic C satisfies $`l^TC^{\star}l=0`$. For a non-singular symmetric matrix $`C^{\star}=C^{-1}`$ (up to scale).

## Tangent lines to conics.
* The line l tangent to C at a point x on C is given by  $`l = Cx`$. 
* Points x satisfying $`x^TCx=0`$ line on a point conic, line l satisfying $`l^TC^{\star}l=0`$ are tangent to the point conic C.

## Degenerate conics
If the matrix C is not of full rank, then the conic is termed degenerate.    
Degenerate point conics include two lines (rank 2), and a repeated line (rank1).    
Degenerate line conics include two points (rank 2), and a repeated point (rank 1). 






