# 定义
The singular value decomposition of a matrix is usually referred to as the SVD.    
We can think of A as a linear transformation taking a vector $`V_1`$ in its row 
space to a vector $`u_1 = Av_1`$ in its column space. The SVD arises from finding 
an orthogonal basis for the row space that gets transformed into an orthogonal basis for the column space: 
$`Av_i = \sigma_i u_i`$ .

可以通过求解特征值和特征向量的方式来得出U和V，如下面公式所示：
```math
\begin{aligned}
A=U \Sigma V^T \\
A^T A = V \Sigma^2 V^T \\
A A^T = U \Sigma^2 U^T \\
\end{aligned}
```

# 应用
## 求线性优化的解或求伪逆
```math
A^+=V \Sigma ^{-1} U^T
```
## 主成份分析（PCA）
## 图像、信号或矩阵压缩
## 列空间、零空间和秩
奇异值分解的另一个应用是给出矩阵的列空间、零空间和秩的表示。
对角矩阵 $`\Sigma`$ 的非零对角元素的个数对应于矩阵 M的秩
。与零奇异值对应的右奇异向量生成矩阵 M的零空间，与非零奇异值对应的左奇异向量则生成矩阵M的列空间。
在线性代数数值计算中奇异值分解一般用于确定矩阵的有效秩，这是因为，由于舍入误差，秩亏矩阵的零奇异值可能会表现为很接近零的非零值。
* 零空间是Av=0所有解v的集合，成叫A的核、核空间
* $`null(A)=V_{r:n},r=rank(a)  -> A V_{r:n}=0`$

# reference
* https://zh.wikipedia.org/wiki/%E5%A5%87%E5%BC%82%E5%80%BC%E5%88%86%E8%A7%A3
* [MIT open course](https://ocw.mit.edu/courses/mathematics/18-06sc-linear-algebra-fall-2011/positive-definite-matrices-and-applications/singular-value-decomposition/MIT18_06SCF11_Ses3.5sum.pdf)