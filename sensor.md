# Euler angle
![oculus_head_model](/uploads/07b3056d8042f57bb91b2fb509ee0189/oculus_head_model.jpg)

# Head model
To obtain a head model, the rotation center is moved so that orientation
changes induce a plausible translation of the eyes. The height h is along the y axis,
and the protrusion p is along the z axis (which leads a negative number).
```math
T_{head}=\begin{pmatrix}\\
1 & 0 & 0 & 0 \\
0 & 1 & 0 & h \\
0 & 0 & 1 & p \\
0 & 0 & 0 & 1 \\
\end{pmatrix}
```
The idea is to choose h and p that would correspond to the center of rotation of the
head. The parameter h is the distance from the rotation center to the eye height,
along the y axis. A typical value is h = 0.15m. The protrusion p is the distance
from the rotation center to the cyclopean eye. A typical value is p = −0.10m,
which is negative because it extends opposite to the z axis. Using a fake head
model approximates the eye locations as the user rotates her head; however, it is
far from perfect. If the torso moves, then this model completely breaks, resulting in
a large mismatch between the real and virtual world head motions. Nevertheless,
this head model is currently used in popular headsets, such as Samsung Gear VR.
# viar
```
    Vector3f Acceleration;  // Acceleration in m/s^2.
    Vector3f RotationRate;  // Angular velocity in rad/s.	
    Vector3f MagneticField; // Magnetic field strength in Gauss.
    Vector3f MagneticBias;  // Magnetic field calibration bias in Gauss.
    float    Temperature;   // Temperature reading on sensor surface, in degrees Celsius.
    float    TimeDelta;     // Time passed since last Body Frame, in seconds.
```
# 温度的影响
gyroscope outputs are sensitive to the particular temperature
of the MEMS elements. If a VR headset heats up during use, then calibration
parameters are needed for every temperature that might arise in practice. Fortunately,
IMUs usually contain a temperature sensor that can be used to associate
the calibration parameters with the corresponding temperatures.

产品设计时要考虑将IMU远离SOC芯片。

# 校准
针对VR设备中的IMU传感器通过融合陀螺仪、加速度计、磁力计的测量数据来进行姿态估计。陀螺仪在静止状态下的数据也不是全零状态，是有零偏误差的，一般在出厂的时候会对陀螺仪进行校正，算出零速率偏移。软件获取到校正过后的数据，但这个数据仍然不是全零的，是具有一定误差，并且会随时间变化不断漂移，因此通过融合加速度计及磁力计的数据能够来继续对数据进行补偿。

陀螺仪的误差主要来源是两方面，一个是陀螺仪的零速率偏移，另一个是陀螺仪的静态随机偏差。在出厂的时候，一般会对陀螺仪进行校准，算出零速率偏移，在后续计算时再减去这个零速率偏移。但是陀螺仪的静态随机漂移会随时间的变化而产生随机性的漂移，这样的话姿态估计还是不准确的

* 实验室校准  在实验室测试不同测试、不同磁场以及其它环境因素下的理论数据，一般是个小样本数据。
* 工厂校准  出厂时，在实验室数据的基础上，在本机上使用实验室数据，进行进一步校正，更新实验室数据个体的差异。工厂很难像实验室一样做到每个环境下进行校准，可能只是在工厂环境条件下计算当前偏差，更新到实验室数据。
* 自动校准 在实际运行时，根据使用者当前的温度和环境进行校准，更新出厂后的实验室数据。只更当前使用温度下的数据，随着使用场景的增多，自动校准数据会越来越全面。

# Sensor的实时性
with a SCHED_FIFO device manager thread for sensor input

# Sensor预测的时机
Before getting sensor input, the application also needs to know when the images that are
going to be synthesized will be displayed, because the sensor input needs to be predicted
ahead for that time.

# vrlib sensor flow
```
DeviceManager-onEvent->HIDDevice  XXXDevice--onInputReport-->SensorDeviceImpl-->SensorFusion
```
陀螺仪上报的三个方向的转动角度，angle是三个方向角度的模，w=cos(0.5*angle)， x=axis.x * sin(0.5*angle)，y=axis.y*sin(0.5*angle)，z=axis.z*sin(0.5*angle)

数据解析流程
```
MPU->陀螺仪零速率偏移校正->陀螺仪数据标准化->转化为四元数->姿态
```
# sensor fusion
sensor fusion can reduce the tracking latency to about 1 ms.
## Sensor Filter
*  Kalman filter is the optimal estimator for **linear systems** with linear measurements and Gaussian noise, but their performance outside of that range is not guaranteed. Furthermore, the method is appropriate for systems with a lower sampling rate and a high degree of predictability due to a stronger motion model. 
* Particle filters are more suited for problems in which the world state is enormous, which might include, for example, models of the surrounding obstacles (think about robots mapping their environment). 
* The complementary filter, which combines high-pass filtering of gyroscope data with low-pass filtering of accelerometer data. For a comparison of these approaches to Kalman filters, see [Higgins, W. T., A Comparison of Complementary and Kalman Filtering, IEEE Transactions on Aerospace and Electronic Systems, Volume 11, Issue 3, pp. 321-325, 1975.]

## Drift correction
* Drift in the pitch and roll angles is called** tilt** error, which corresponds to confusion about which way is up. 
* Drift in the yaw angle is called **yaw **error, which is confusion about which way is North, or at least which way you are facing relative to when you started. 

## Tilt error correction
当前方向在xz面上的投影向的垂直向量做为方向校正的旋转轴。延着此轴转动thita角度。

![tilt01](/uploads/c3c2d583cb665dc6590e714af7aeacc7/tilt01.png)

![tilt21](/uploads/36d3273b3b2c2003987d884ccb1ce290/tilt21.png)

## vrlib sensor correction

```
void SensorFusion::handleMessage(const MessageBodyFrame& msg) {
	// Tilt correction based on accelerometer
	if (EnableGravity)
		applyTiltCorrection(DeltaT);
	// Yaw correction based on magnetometer
	if (EnableYawCorrection && HasMagCalibration())
		applyMagYawCorrection(mag, magBias, gyro, DeltaT);

	// Store the lockless state.
	StateForPrediction state;
	state.State = State;
	state.Temperature = msg.Temperature;
//	RecenterMutex.DoLock();
	UpdatedState.SetState(state); 	
```
# sensor predict

```
// This is a "perceptually tuned predictive filter", which means that it is optimized
// for improvements in the VR experience, rather than pure error.  In particular,
// jitter is more perceptible at lower speeds whereas latency is more perceptable
// after a high-speed motion.  Therefore, the prediction interval is dynamically
// adjusted based on speed.  Significant more research is needed to further improve
// this family of filters.
Posef calcPredictedPose(const PoseStatef& poseState, float predictionDt) {
		pose.Orientation = pose.Orientation
				* Quatf(angularVelocity, angularSpeed * dynamicDt);
}
```


# ref
https://github.com/memsindustrygroup/Open-Source-Sensor-Fusion/

http://smus.com/sensor-fusion-prediction-webvr/

http://www.pieter-jan.com/node/11

http://www.codeproject.com/Articles/729759/Android-Sensor-Fusion-Tutorial
