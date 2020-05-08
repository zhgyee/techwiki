# 向量运算
## 内积或点积
### 定义
 ![](https://wikimedia.org/api/rest_v1/media/math/render/svg/d7de7b9aa6a9bbc6f6435c24173c0597464c8420)
[see viki](https://zh.wikipedia.org/wiki/%E6%95%B0%E9%87%8F%E7%A7%AF)
### 几何意义
* 标量投影
* 向量夹角

## 外积或叉积
### 定义
![](https://wikimedia.org/api/rest_v1/media/math/render/svg/f0aa2d916cf302f911edfdca957231c820b7e618)

### 几何意义
因此两支向量叉积的模长可视作平行四边形其面积    
![](https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Cross_product_parallelogram.svg/480px-Cross_product_parallelogram.svg.png)

## Skew-symmetric matrix 表示叉积
3x3 skew symmetric matrices can be used to represent cross products as matrix multiplications. Consider vectors $`a=(a_1,a_2,a_3)^T`$, $`b=(b_1,b_2,b_3)^T`$, then define matrix:
```math
{[a]}_x=
\begin{pmatrix}
0 & -a_3 & a_2\\ 
a_3 & a_0 & -a_1\\ 
-a_2 & a_1 & 0
\end{pmatrix}
```
the cross product can be written as:
```math
a \times b = {[a]}_x b
```

This can be immediately verified by computing both sides of the previous equation and comparing each corresponding element of the results. See detail: [wiki](https://en.wikipedia.org/wiki/Skew-symmetric_matrix)

## 三重积
### 标量三重积 triple scalar product identity
![标量三重积](https://wikimedia.org/api/rest_v1/media/math/render/svg/88cc336d46a0931b1d9d6b45f28ad8fc07849f98)    
[see viki](https://zh.wikipedia.org/wiki/%E4%B8%89%E9%87%8D%E7%A7%AF)    
$` l \cdot (l \times l') = l' \cdot (l \times l') `$
### 向量三重积
雅可比恒等式 ![雅可比恒等式](https://wikimedia.org/api/rest_v1/media/math/render/svg/3b7681545194bad32f08216370bcafa431735c12)    
拉格朗日公式 ![拉格朗日公式](https://wikimedia.org/api/rest_v1/media/math/render/svg/d8f5ab653b62f34e9e02e8addb76e3572c5032dc)

### 几何意义
几何上，由三个向量定义的平行六面体，其体积等于三个标量标量三重积的绝对值    
![](https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Parallelepiped_volume.svg/240px-Parallelepiped_volume.svg.png)