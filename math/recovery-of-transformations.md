# Overview
* the projective distortion may be removed once the image of  $`l_{\infty}`$ is specified, 
* and the affine distortion removed once the image of the circular points is specified. 
* Then the only remaining distortion is a similarity.

# Recovery of affine properties from images 恢复仿射性质
 transform the identified $`l_{\infty}`$ to its canonical position of $`l_{\infty} = (0, 0, 1)^T`$. The
(projective) matrix which achieves this transformation can be applied to every point
in the image in order to affinely rectify the image, i.e. after the transformation, affine
measurements can be made directly from the rectified image.

If the imaged line at infinity is the line $`l = (l_1, l_2, l_3)^T`$, then provided $`l_3  \ne 0`$ a suitable
projective point transformation which will map l back to $`l_{\infty} = (0, 0, 1)^T`$ is:
```math
H=H_A\begin{pmatrix} \\
1 & 0 & 0 \\
0 & 1 & 0 \\
l_1 & l_2 & l_3 \\
\end{pmatrix}
```