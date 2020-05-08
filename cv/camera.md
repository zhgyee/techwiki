# [camera model](cameramodel.md)
# [CameraCalibration](camera-calibration.md)
# 双目相机模型
![双目视差](/uploads/efbfa363f4bf08beacff5652b3beff6e/双目视差.PNG)

根据三角形P-PL-PR与P-OL-OR相似得出：
```
(z-f)/z = (b-ul-ur) / b
z=fb/d, 其中d = ul-ur
```
这里d称为视差，通过视差可以估计一个物体离相机的距离。
