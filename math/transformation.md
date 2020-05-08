# overview
二维射影变换是将一个平面的点映射成另外一个平面的点，三维投影也同理，只是维度更高，将一个三维坐标系映射成另外一个三维坐标系。
# 射影变换 Projective transformation
A planar projective transformation is a linear transformation on homogeneous 3-vectors represented by a non-singular 3 × 3 matrix,
$`x'=Hx`$
# 透视变换 Perspectivity transformation
 Actually, if the two coordinate systems defined
in the two planes are both Euclidean (rectilinear) coordinate systems then the mapping
defined by central projection is more restricted than an arbitrary projective transformation.
It is called a **perspectivity rather than a full projectivity**, and may be represented
by a transformation with **six degrees of freedom**.
# 直线与二次曲线的射影变换
在点变换 $`x'=Hx`$ 下
* 直线l的变换为$`l'=H^{-T}l`$
* 二次曲线C的变换为$`C'=H^{-T}CH^{-1}`$
* 对偶二次曲线的变换为 $`C^{\star}{'}=HC^{\star}H^T`$

# Isometries 等距变换
![Screenshot_from_2017-03-07_16_33_13](/uploads/c14b3db0410e31ca3646b41599384b02/Screenshot_from_2017-03-07_16_33_13.png)    
where = ±1. If = 1 then the isometry is orientation-preserving and is a Euclidean
transformation (a composition of a translation and rotation). If = −1 then the isome-
try reverses orientation. An example is the composition of a reflection, represented by
the matrix diag(−1, 1, 1), with a Euclidean transformation.

欧式变换或刚体变换，不变量：
* 长度
* 角度
* 面积

# Similarity transformations 相似变换
![Screenshot_from_2017-03-07_16_38_24](/uploads/fdbd471007d4915b5e6c565d0bdfe340/Screenshot_from_2017-03-07_16_38_24.png)    
s表示均匀缩放，相似变换也称为等形变换，不变量：
* 角度
* 长度的比率保持不变

# Affine transformations 仿射变换
![Screenshot_from_2017-03-07_16_44_59](/uploads/e3b2eb1bdfb7900191dfada98166ad71/Screenshot_from_2017-03-07_16_44_59.png)     
与相似变换相比，仿射变换仅仅多了非均匀缩放。仿射变换的本质是在一个特定角的两个垂直方向上进行缩放。

不变量：
* 平行线
* 平行线段的长度比
* 面积比

# Projective transformations 投影变换
![Screenshot_from_2017-03-07_16_54_06](/uploads/b961599e9510acf1d9b221e08895956d/Screenshot_from_2017-03-07_16_54_06.png)

![Screenshot_from_2017-03-07_16_54_56](/uploads/fcf16cfde50ce2ae792daba8cfaebac9/Screenshot_from_2017-03-07_16_54_56.png)    
The inverse of H gives $`H^{-1}=H_P^{-1}H_A^{-1}H_S^{-1}`$，H也可表示为：    
![InverseOfH](/uploads/65da3855b1ff6655e85e277c89f9195e/InverseOfH.PNG)



投影变换可以看做先通过矢量V进行非线性变化，然后再进行仿射变换以及相似变换。投影变换的分块：
* A 仿射变换（旋转加上比例缩放）
* t 平移变换
* $`v^T`$ 对理想点的变换，与仿射变换的区别点    
![projective_transformation](/uploads/fb29dad1b98ca2e13314d4d1bb81b77f/projective_transformation.PNG)


![Screenshot_from_2017-03-07_17_06_53](/uploads/abe9cbbc64dee07b9b447a0bb36b609c/Screenshot_from_2017-03-07_17_06_53.png)


