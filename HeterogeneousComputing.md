# CP-- command processor
A CP keeps track of states within the GPU, updates host mapped registers and signals interrupts to inform the CPU.
In fact, CPs are (afaik) a micro-processors embedded into the GPU capable of doing most of the tasks traditionally handled by software at the driver. Contains an internal memory, can do complex logic, arithmetic operations and so on. Its capable of managing multiple command buffers, keep track of what is sent down into the GPU or update fences once the command stream has reached them.

# GPU
移动GPU在通用计算方面（GPGPU）主要包括OpenCL、shader、renderscipt等。
   NVIDIA      CUDA
   Intel           TBB，Cilk
   MS              PPL
   Apple          GCD
   Khronos      OpenCL
   Google        RenderScript
# DSP
高通的Hexagon DSP目前主要用在voice/audio方面，比如 麦克风降噪、声音特效等。
DSP是长指令系统，是典型的单指令多数据（SIMD）的体系结构，它不擅长逻辑控制，但是确实天生的向量计算机器，他虽然是单核的，但是支持超 线程，所以功耗只有CPU的十分之一。
高通已经开始逐步开放Hexagon DSP SDK给客户使用，比如我们公司的无人机项目的飞控模块就是运行在DSP上，还有VR/AR的一些 数字图像处理等。
#低功耗管理技术
现在，为了延长便携式设备(如手机、MP3、多媒体播放器、笔记本电脑等)的电池寿命，芯片厂商们正在绞尽脑汁开发新的节电技术。简单地说，这些节电技术可以分为两类——动态技术和静态技术。静态技术包括不同的低功耗模式，芯片内部不同组件的时钟或电源的按需开关等。动态技术则是根据芯片所运行的应用程序对计算能力的不同需要，动态调节芯片的运行频率和电压(对于同一芯片，频率越高，需要的电压也越高)，从而达到节能的目的。该技术的理论依据是如下的公式：   

`P=aCV^2F`
`E=Pt=aCV^2Ft`

 从上面的公式可以看出，降低频率可以降低功率，但是单纯地降低频率并不能节省能量。因为对于一个给定的任务，F*t是一个常量，只有在降低频率的同时降低电压，才能真正地降低能量的消耗。
目前许多芯片支持DVFS，比如InteI公司的芯片支持SpeedStep，ARM的支持IEM(Intelligent Energy Man-ager)和AVS(Adaptive Voltage Scaling)等。但是要让DVFS发挥作用，真正地实现节能，只有芯片的支持还是不够的，还需要软件与硬件的综合设计。

## 降低电压
高电压是造成功耗提升的另一个重要因素，电压与功耗总是成正比关系。
在CPU中，最大功耗可由核心电压×最大电流简单计算而估得。通常CPU内部的电流都较大，而且是不易减小的，因此，虽然供给CPU的电压并不高，但与大电流相乘后，带来的功耗也是不容忽视的。所以，降低电压，即使降低的幅度不太大，所带来的功耗下降也将相当明显。但是如果电压降得过低，CPU内部的CMOS管就会变得不稳定，工作可靠性也随之大大降低。
## 降低频率
实际上，过于注重频率的提升，也是导致CPU功耗日益加大的重要因素。
之前，人们一直认为频率是衡量CPU性能的最重要标志，频率并不等于性能的说法直到近几年才被意识到。
提高频率有很多方法，如采用全新的设计、提升电压、制程提升等，但更为简单直接的却是采用超长流水线设计。在此设计中，CPU的流水线被划分得相当细密，频率提升的空间也相应增大，这就如同更细密的生产流水线拥有更高的效率一样。但是问题在于，流水线过多，其延时和错误率也会增加，最终导致CPU效率直线下降，性能反而不佳。
## reference
http://share.onlinesjtu.com/mod/tab/view.php?id=309
http://blog.csdn.net/xuxuyoyo/article/details/12780527