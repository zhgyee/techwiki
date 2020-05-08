# 概念
![homography](/img/homography.PNG)

单应是投影平面到另外一个投影平面的影射。
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
# 参考
* [推导单应矩阵](https://www.zhihu.com/question/23310855)
* https://en.wikipedia.org/wiki/Homography
