# 介绍
可以在web页面上支持数学公式显示。

```math
\begin{aligned}
R=mR_s \\
R_v=D(R_s) \\
R_v=R+\Delta R \\
\Delta R=kR^3+hR^5+\ldots \\
R_v=D(R_s)=mR_s+k(mR_s)^3 \\
distortionRate=100 \frac{k(mR_s)^3}{mR_s}=100k(mR_s)^2 \\
R_i=D^{-1}(R) \text{    预畸变点在屏幕的位置}\\
R_i=D^{-1}(R)=\sqrt[3]{-\frac{q}{2}+\sqrt{\frac{p}{3}^3 + \frac{q}{2}^3}} + \sqrt[3]{-\frac{q}{2}-\sqrt{\frac{p}{3}^3 + \frac{q}{2}^3}}\text{  where  }p=\frac{1}{m^2k} \text{ and } q=-\frac{R}{m^3k}
\end{aligned}
```

# 示例
```
\begin{aligned}
H=\begin{pmatrix}h_1 \\ h_2 \\ h_3  \end{pmatrix} \\
P=K[R t]=H \\
r_1=k^{-1}h_1 / \Vert k^{-1}h_1 \Vert \\
r_2=k^{-1}h_2 / \Vert k^{-1}h_1 \Vert \\
r_3=r_1 \times r_2 \\
t=k^{-1}h_3 / \Vert k^{-1}h_1 \Vert \\
\end{aligned}


```

```math
\begin{aligned}
H=\begin{pmatrix}h_1 \\ h_2 \\ h_3  \end{pmatrix} \\
P=K[R t]=H \\
r_1=k^{-1}h_1 / \Vert k^{-1}h_1 \Vert \\
r_2=k^{-1}h_2 / \Vert k^{-1}h_1 \Vert \\
r_3=r_1 \times r_2 \\
t=k^{-1}h_3 / \Vert k^{-1}h_1 \Vert \\
\end{aligned}

```

```
{[a]}_x=
\begin{pmatrix}
0 & -a_3 & a_2\\ 
a_3 & a_0 & -a_1\\ 
-a_2 & a_1 & 0
\end{pmatrix}
```

```math
{[a]}_x=
\begin{pmatrix}
0 & -a_3 & a_2\\ 
a_3 & a_0 & -a_1\\ 
-a_2 & a_1 & 0
\end{pmatrix}
```
# 符号对照
* http://www.intmath.com/cg5/katex-mathjax-comparison.php
* https://github.com/Khan/KaTeX/wiki/Function-Support-in-KaTeX
