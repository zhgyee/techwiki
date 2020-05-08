# 定位指标
* 6DOF（不仅能够追踪旋转，也能追踪移动），360度追踪（不管朝向哪个方向都能追踪到6DOF）；
* 毫米级或更高精确度，无颤抖噪音（被追踪物体静止时不会出现抖动）；
* 舒适的追踪范围（头盔所处的空间定位面积）。
* 从运动发生到显示在屏幕上的时间差<20ms，即，延迟<20ms，刷新率>50Hz。
* 必须满足多人同时使用。

# 主要的空间定位技术
![traking-comparing](traking-comparing.jpg)

## 运动测量法IMU
二次积分引很大的累积误差，只有快速的reset才能跟踪小范围的位移。

When tracking position based on accelerometer data using dead reckoning, drift accumulates quadratically, meaning that the speed of drift increases proportionally to time passed.

You can use an IMU for position determination if it has a low accelerometer-noise level. Those IMU's are unfortunately very expensive and the position still drifts away after some time. The video in your link (tracking a foot) shows position determination of an IMU, yes, but it only works because for one reason: the integrated value can be reset each time the foot is on the floor (no acceleration). So what can you do if you don't have the opportunity e.g. how would you track the position of a rc-plane? 

Regarding to the kalman filter: A kalman filter makes sense if you have more than one sensor input. But for tracking a position, the only sensor which makes sense to use is the accelerometer (unless you also have a GPS, wheel speed sensor etc.). So what would be your second sensor then?﻿
## 光学测量法（PSVR、Oculus、Optitrack、TheVoid、ZeroLatency）
Daniel DeMenthon和Larry S. Davis在1995年在International Journal of Computer Vision发了一篇论文， 'Model-Based Object Pose in 25 Lines of Code'。

这篇论文建立了一套我们称为POSIT的方法，这套方法建立了整套光学定位的基础。POSIT是通过透视结果（近大远小）计算出物体相对于光线采集设备（比如CMOS）的旋转和位移。
没错， POSIT能直接计算出完整的一阶位置和旋转数据。但是，光学定位都需要外部相机。Oculus配备了Constellation，PSVR 比较坏没有包含，但是必须有PS Eye才可以使用PSVR，也是个相机。

比如Oculus，用的是红外LED发光，用没有红外滤镜的摄像头看就是这个样子。取得这张图片，然后用blob detect找到所有点的位置，然后用POSIT方法用点在图片中的x,y位置和原始的三维的位置x,y,z（设计时已知了）就可以计算出Oculus的6DOF。

前面提到Oculus同时有IMU提供的3阶位置和2阶及1阶角度数据和光学定位计算出来的1阶位置和角度数据，每个数据有自己的噪音，需要一个方法来计算出一组唯一的数据。我们比较确定的是，Oculus用了一种R.E.Kalman在1960年的论文“A New Approach to Linear Filtering and Prediction Problems”提出的算法来融合和计算出唯一的6DOF数据。

值得一提的是，因为获得数据（图像和IMU采集）的时间T0，计算完成时间T1，和最后画面投在显示屏上的时间T2之间有差（前面提到T2-T0<25ms）。所以这一套Kalman模型并不是直接给出T0信息的计算结果，而是通过2阶数据的计算预测出T2时的数据。这才是真正给出的6DOF，这就是世界最高标准定位算法的追求。 

光学定位就是对计算机成像（pin hole model）的逆运算，如果熟悉线性代数会很容易理解计算过程。
因为光学采集是FOV固定，CMOS分辨率固定，因此捕捉分辨率和距离成反比。


## 视频测量法VIO/SLAM（Hololens 和 Tango）
## Lighthouse（HTC Vive）
## ToF (UWB，光，声)

# ref
[跟Hoevo缪庆学习VR/AR/MR的空间定位技术 | 硬创公开课](https://m.leiphone.com/news/201606/UBe8TIThpCsjk7Ir.html?viewType=weixin)