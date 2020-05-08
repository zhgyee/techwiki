# IMU Noise Model
https://github.com/ethz-asl/kalibr/wiki/IMU-Noise-Model
# IMU 标定库
## IMU_TK
Imu_tk算法流程

由于VIO中，普遍使用的是精度较低的imu，所以其需要一个较为准确的内参数和noise的估计。
Noise大家通常使用Allan方差进行估计可以得到较为可信的结果，这里不赘述了。
内参数标定比较方便的一个工具就是imu_tk。所以本篇文章主要详细介绍一下imu_tk的算法流程以及使用时的注意事项。
下一篇的内容 计划是imu-camera外参数的标定方法。

首先分步介绍算法流程:

1. 读入数据，将时间单位转化为秒

2. 设置初始参数和标定算法的控制参数

3. 开始标定

3.1 标定加速度计

首先调用initiInterval函数，返回前50s(默认是30s)的数据的index

计算初始的init_static_interval的方差，定义为norm_th

For循环：th_mult=2:10

{利用大小为101的滑动窗口搜索静止区间：如果该滑动窗口内的加速度计读数的方差小于th_mult*norm_th，则认为是静止区间

提取出静止区间内的加速度计读数。如果某个区间的大小小于初始设置的interval_n_samples_（默认是100）则去除该静止区间；注意，如果初始参数中acc_use_means_为true，则在静止区间内只取所有读数的平均值作为static_sample，且其时间戳为静止区间的时间戳的中值。否则保存所有的静止区间内的sample。如果提取出的静止区间个数小于初始设置的min_num_intervals_（默认是12），则认为采集的数据不足以标定imu，则程序退出。

构造目标函数：g-unbiasnorm(acc_samples)，其中前者为初始设置的重力加速度值，后者为去除bias以后的加速度计读数的norm。因为如果imu静止，则其加速度计的读数的模应当等于重力加速度的值。

利用ceres最小化目标函数得到加速度计的九个参数。并利用标定得到的参数将加速度计的raw_data进行修正。

}

th_mult在2~10时最小的估计误差对应的参数为最准的加速度计标定参数，同时保存该参数对应的static_interval。

3.2 标定陀螺仪

根据加速度计的标定结果，提取static_sample。

根据初始的50s的陀螺仪读数，估计陀螺仪的bias。

利用上步得到的bias矫正陀螺仪读数。

根据提取的static_interval找到运动区间的start_index和end_index。

构造目标函数：integrate_R’*g_start-g_end。其中g_start和g_end均是归一化后的向量。因为在imu运动区间内，两帧加速度计的读数之间应当是两帧间imu的旋转，也就是imu的陀螺仪积分后得到的结果。

利用ceres最小化目标函数得到陀螺仪的十二个参数。注意，如果初始optimize_gyro_bias_为true，则在矫正陀螺仪读数后仍然需要标定bias参数，否则返回初始读数估计得到的bias。gyro_dt_如果为-1，则利用两帧陀螺仪的timestamp进行积分，否则利用gryo_dt给定的时间间隔进行积分。

注意事项：

1. 标定时，首先需要将imu静止一段时间，根据程序可知，至少需要静止50s以上。

2. 由于程序中检测静止区间的滑动窗口大小为101，所以每次静止时间需要超过100帧数据

3. 由于程序中检测静止区间时，需要至少end_index开始的滑动窗口内的方差大于2倍的静止方差，所以每两次静止区间之间的运动时间不能太短，且最好是有明显的加速或减速运动。最好运动时间超过100帧。

4. 由于程序中需要检测到的静止区间数大于12，且论文中提到静止区间为30+~40+次时，精度较好。所以需要有大概30多次的静止区间。

5. 静止区间内尽量保证imu是静止不动的。初始的1分钟中内尤其要保持imu静止，以得到较好的norm_th的估计和gyro_bias的估计。

参考文献：

Tedaldi D, Pretto A, Menegatti E. A robust and easy to implement method for IMU calibration without external equipments[C]//2014 IEEE International Conference on Robotics and Automation (ICRA). IEEE, 2014: 3042-3049.
## imu utils
https://github.com/gaowenliang/imu_utils

https://github.com/XinLiGH/GyroAllan
# 参考文档
* Calibration and performance evaluation of low-cost IMUs 提供imu-tk程序实现论文中算法
* MEMS-IMU随机误差的Allan方差分析  http://www.doc88.com/p-0873595150670.html
* IMU-Camera校准 https://github.com/ethz-asl/kalibr/wiki/IMU-Noise-Model  
* IMU误差模型和校准 https://www.cnblogs.com/buxiaoyi/p/7541974.html ---比较好的融合了上述文献