# htc畸变调试
## 關於Distortion “r” value
目前我們Distortion是參考OpenGL的做法，在OpenGL 裡X跟Y會被mapping到0~1之間
所以r值會小於1，根據下列公式,越高次項影響會越小，如果調整K0 則是會改變影像大小，一般是設1，(如果要改影像大小，可以修改這個值)
在調整K值時(如果只條偶次項)，先調K2，再調K4，最後是K6
最後在顯示時，OpenGL才會把XY貼回顯示大小。
 
我們建議,你們可以分別用3個顏色的方格圖，放到實際device裡，再用人眼方式去看，然後調整K2~K6值讓影像變回正常方格
      一般來說可以先調出紅色的，另外兩個顏色照這個參數再微調
```math
\begin{aligned}
x_d=x_u(k_{offset}+k_0r^0+k_1r^1+...+k_6r^6) \\
y_d=y_u(k_{offset}+k_0r^0+k_1r^1+...+k_6r^6) \\
(x_d, y_d)=\text{distorted image point as projected on image plane using specified lens} \\
(x_u, y_u)=\text{undistorted image point as projected by an idle pin-hole camera} \\
r=\sqrt{(x_u-x_c)^2+(y_u-y_c)^2} 
\end{aligned}
```
根据上面公式， r的实际范围为0~0.5，拟合时要规一化到此区间

## 關於randerOverfillFactor
這個參數設置後，影像會變大，但是FOV會變小，所以不建議修改
 
## Lens中心和螢幕中心不相對
這個部分是建議將調整ipd試試看，建議調成58mm~60mm

# FOV计算
在renderconfig.renderOverfillFactor=1的情况下，投影矩阵如下：
```
ProjectionLeft =
 ⎡+1.287711  +0.000000  -0.016949  +0.000000⎤
 ⎢+0.000000  +1.151135  +0.000000  +0.000000⎥
 ⎢+0.000000  +0.000000  -1.006689  -0.200669⎥
 ⎣+0.000000  +0.000000  -1.000000  +0.000000⎦
ProjectionRight =
 ⎡+1.287711  +0.000000  +0.016949  +0.000000⎤
 ⎢+0.000000  +1.151135  +0.000000  +0.000000⎥
 ⎢+0.000000  +0.000000  -1.006689  -0.200669⎥
 ⎣+0.000000  +0.000000  -1.000000  +0.000000⎦
EyePosLeft =
 ⎡+1.000000  +0.000000  +0.000000  +0.029000⎤
 ⎢+0.000000  +1.000000  +0.000000  -0.054000⎥
 ⎢+0.000000  +0.000000  +1.000000  -0.000000⎥
 ⎣+0.000000  +0.000000  +0.000000  +1.000000⎦
EyePosRight =
 ⎡+1.000000  +0.000000  +0.000000  -0.029000⎤
 ⎢+0.000000  +1.000000  +0.000000  -0.054000⎥
 ⎢+0.000000  +0.000000  +1.000000  -0.000000⎥
 ⎣+0.000000  +0.000000  +0.000000  +1.000000⎦
```
对应的FOV分别为fovx=75.66 fovy=81.96

在renderconfig.renderOverfillFactor=1.4情况下，投影矩阵如下：
```
ProjectionLeft =
 ⎡+0.919794  +0.000000  -0.016949  +0.000000
 ⎢+0.000000  +0.822239  +0.000000  +0.000000
 ⎢+0.000000  +0.000000  -1.006689  -0.200669
 ⎣+0.000000  +0.000000  -1.000000  +0.000000
ProjectionRight =
 ⎡+0.919794  +0.000000  +0.016949  +0.000000
 ⎢+0.000000  +0.822239  +0.000000  +0.000000
 ⎢+0.000000  +0.000000  -1.006689  -0.200669
 ⎣+0.000000  +0.000000  -1.000000  +0.000000
EyePosLeft =
 ⎡+1.000000  +0.000000  +0.000000  +0.029000
 ⎢+0.000000  +1.000000  +0.000000  -0.054000
 ⎢+0.000000  +0.000000  +1.000000  -0.000000
 ⎣+0.000000  +0.000000  +0.000000  +1.000000
EyePosRight =
 ⎡+1.000000  +0.000000  +0.000000  -0.029000
 ⎢+0.000000  +1.000000  +0.000000  -0.054000
 ⎢+0.000000  +0.000000  +1.000000  -0.000000
 ⎣+0.000000  +0.000000  +0.000000  +1.000000
```
对应的FOV分别为fovx=94.78 fovy=101.14

透視矩陣在產生時會用到renderconfig.renderOverfillFactor這個參數去把FOV放大。renderOverfillFactor的作用是focalLength/renderOverfillFactor

FOV越大，可能会造成平板翘曲的现象，FOV越小，桶形可能会更严重，理论上几何FOV跟光学FOV一致是最后合适的。

FOVX和FOVY是否一致要看eye buffer size，如果w=h的话，FOV一致，如果有宽高比，那FOV也根据宽高比调整。比如SteamVR中，上层渲染宽高应该是1:1的，所以FOV要求也是1:1，但wave sdk中又相反。