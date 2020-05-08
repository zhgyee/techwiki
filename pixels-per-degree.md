If the human eye was a digital camera, its ‘data sheet’ would say that it has a sensor capable of detecting **60 pixels/degree** at the fovea (the part of the retina where the visual acuity is highest). For visual quality, any display above 60 pixels/degree is essentially wasting resolution because the eye can’t pick up any more detail. This is called retinal resolution, or eye-limiting resolution.

This means that if there an image with 3,600 pixels (60 x 60) and that image fell on a 1° x 1° area of the fovea, a person would not be able to tell it apart from an image with 8,100 pixels (90 x 90) that fell on a 1° x 1° area of the fovea.

# 像素每度 pixels per degree
像素每度是在用户视野中，沿某一方向，每个单位角度内能够看到的显示设备所输出像素的数量。

横向与纵所能看到的最大像素数为$`P_x, P_y`$，每个像素宽度为a,出瞳距离为L，则由几何关系可知设备的角分辨率为：
```math
{\alpha}_x=\frac{P_x}{2arctan{\frac{P_x \cdot a}{2L}}}


{\alpha}_y=\frac{P_x}{2arctan{\frac{P_y \cdot a}{2L}}}
```
![ppd](/uploads/af9bd779aa815614627824f0e7a260eb/ppd.PNG)

## 通过FOV计算ppd
If you have a VR headset, you can calculate the pixel density—how many pixels per degree it presents to the eye—by dividing the number of pixels in a horizontal display line by the horizontal field of view provided by the lens. For instance, the Oculus Rift DK1 dev kit (yes, I know that was quite a while ago) used a single 1280 x 800 display (so 640 x 800 pixels per eye) and with a monocular horizontal field of view of about 90 degrees, it had a pixel density of just over 7 pixels/degree (640 ÷ 90). You’ll note that this is well below the retinal resolution of 60 pixels per degree.

