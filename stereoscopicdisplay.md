the object's images are projected
onto the retinas, and the retinal images depend only on the object's shape and the relative position of the two eyes with
respect to the object.

For the display software to generate the images required to give the HMD-user the perception of
undistorted objects, the software must take into account the physical geometry of each hardware component that affects the
final image seen by the eyes. This geometry includes the **display screens**, the **optics** used to image the displays, and the **placement** of the displays with respect to the eyes.

# 3D显示常见的问题
## Incorrect convergence. 
In the real world, the eye adjusts to depth in a scene in two ways, **convergence and focus**. 
在现实世界中，人眼调节场景深度的方法有两种，一种是集合和对焦。

看远处的物体，双眼视线是平行的，物体越近，双眼汇聚角越大。

屏幕的中心点与光学镜头中心轴不对齐引起的发散和汇聚的问题。如果两个中心点严格对齐，则中心点像素看上去是无穷远；如果不对齐，则由汇聚引起过近或者由发散引起模糊。竖直方向也存在类似的问题（dipvergence）。

这些偏差可以在计算模型中校正。

## Accommodation not link to convergence. 
眼睛向内汇聚到近物体的同时，眼睛调整物体的距离到不同的焦平面。 由于当前HMD都是固定焦平面，所以当前HMD都存在这个问题。

With respect to focus, the entire virtual image appears at a fixed distance from
the eye. (In a physical scene, different parts of the scene will be in focus at different accomodation depths.)

## Incorrect FOV. 
* physical FOV. 对象点到入瞳中心的最大的角度，也是光学总的FOV（total FOV）
* computational FOV. This computational FOV determines how faraway the center of projection is
from the screen rectangle in the perspective transformation that is used to project the 3D virtual world onto the 2Dscreen.

To get physical FOV and computational FOV right, the
position of the center of projection with respect to the screen should be exactly at the entrance pupil of the eye.    
光学系统、显示到光学系统的距离、FOV共同决定了出瞳上点的位置，如果眼球不在此位置，模型的物体就不真实。

## Failure to use off-center projection when required.
如果屏幕中心与透镜中心不重合，投影中心需要移动到透镜中心。这种情况需要非对称的计算模型。
生成场景时需要结合translation, rotation, [off-center perspective projection](Perspectiveprojection)

## Interpupillary distance ignored.
双眼之间的距离是一个人判断真实世界物体距离的基线。不同的IPD对应不同的汇聚角（convergence angle）.如果没有机械的IPD调整，通过**大的出瞳**，对无穷远的虚像，看到的是大小一致的，但如果不是无穷远，则比较复杂。针对后一种情况，需要在计算模型中使用跟用户一致的IPD。

## Optical distortion ignored.
The first-order polynomial is linear and describes an ideal magnifier with no distortion, and since there are no even
terms appearing in the expansion, the third-order polynomial is the simplest model of distortion.

If the computational FOV is set to match the physical FOV, then
objects in the **center of the field will appear to be the wrong size**. But if the computational FOV is set to make small central
objects appear to be the right size, the objects in the peripheral field will be positioned wrong. The only way to avoid this
unpleasant choice is to **predistort the image** to correct the optical distortion.

畸变引起亮度不均。Distortion causes non-uniform magnification across the field, which causes the brightness also to vary across the field. This
could be compensated for on a pixel-by-pixel basis with a brighiness correction function B(x5,y5), but limitations of space
prevent us from going into this here.

## Transforming only polygon vertices in the presence of non-linearities
对顶点的预畸变校正只是移动了顶点的位置，顶点间的线段通过GPU仍然是直线，从而通过光学看到的依然是曲线，并且之前的连接的点和线可能会变得不相连。

# Optics model for a HMD
## Single eye optics model
![singlel-eye_optics_model](/uploads/3fcd521dad6c0d38af2a739fbdce4a8f/singlel-eye_optics_model.PNG)
* rs--屏幕像素半径
* rv--虚像像素半径

## Stereosopic optics model
From the known position and orientation of the virtual image of the screen relative to the eye, the
Eye-To-Virtual-Image transformation can be calculated to be the correct **mix of translation, rotation, and off-center perspective
projection**. 
* Translation is needed because the eyes are in different positions in space; 
* rotation is needed if the optical axes are not parallel; 
* and the projection is off-center if the screens are off-center from the optical axes.

![Stereoscopic_display_model](/uploads/e5c0019854edf1a31652b7407adb71b9/Stereoscopic_display_model.PNG)

# Computational model for HMD
![ComputationalModelForHMD](/uploads/3e8e80c133c5e2703414e55f1dd992dc/ComputationalModelForHMD.PNG)
```
1/f = 1/Zv + 1/Dob=>Zv
```
# ref
* A Computational Model for the Stereoscopic Optics of a Head-Mounted Display