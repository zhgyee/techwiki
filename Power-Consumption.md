# 影响芯片功耗的因素
数字电路的功耗不外乎两种：一种是动态功耗，消耗于逻辑的转换；另一种是静态功耗，由于CMOS晶体管存在的各种泄漏造成。对于较老的DSP，或者说基于大于130nm工艺的DSP，静态功耗可以忽略不计；但随着工艺不断精微，静态功耗所占的比例越来越大。

## 静态功耗
![](http://focus.ti.com.cn/cn/graphics/shared/contributed_articles/CA_optimize01.gif)
从上图可以看出，随着工作温度上升，静态功耗呈指数级上升，这使得静态功耗在总功耗中所占的比例进一步提高。另外，值得注意的是，温度升高会增加功耗，而功耗增加又使芯片温度进一步升高，温度和功耗这种互相助长的特性使得DSP散热系统的设计显得更为重要。

## 动态功耗
当门发生逻辑状态转换并产生内部结点充电所需的开关电流以及P通道及N通道同时暂态开启引起直通电流时，就会出现动态功耗。通过以下公式可以估算其近似值：
![](http://focus.ti.com.cn/cn/graphics/shared/contributed_articles/CA_optimize02.gif)
其中，Cpd为动态电容，F为开关频率，Vcc为电源电压。上述关系中包含两个重要概念：动态功耗与开关频率呈线性关系，与电源电压呈二次关系。下图列出了TMS320C6455在不同工作频率下的典型功耗。
![](http://focus.ti.com.cn/cn/graphics/shared/contributed_articles/CA_optimize03.gif)
另外，最大安全开关频率往往取决于电源电压，所以这两者是相互关联的。以TMS320C6455为例，当工作频率小于或等于850MHz时，其要求的核电压为1.2V；而当工作频率大于850MHz时，其核电压必须为1.25V。

# DDR bandwidth
The power consumed reading or writing to an external DRAM will vary with system design, but it can easily be around 120mW for each 1GByte/s of bandwidth provided.     
Internal memory accesses are approximately an order of magnitude less energy intensive than this.    
读取或写入外部 DRAM 的功耗因系统设计而异，但对于提供的每 1GB/s 带宽，它很容易达到大约 120mW。与这相比，内部内存访问的功耗要大约少一个数量级，所以你会发现这真的大有关系。
[ref](https://community.arm.com/groups/arm-mali-graphics/blog/2014/02/20/the-mali-gpu-an-abstract-machine-part-2)
![](http://images.anandtech.com/doci/9330/lpddr4-power-scaling_575px.png)

# A53
CPU首先来看A53部分的，使用模拟负载逐步加压，测量不同核心数量、不同频率下的功耗值，然后绘出变化曲线。曲线非常平稳，说明功耗是正常变化的。单个核心在1.5GHz最高频率下只有367毫瓦，而四个核心全部满载也才刚刚超过1瓦。虽然略高于Exynos 5433，但别忘了频率也提高了200MHz，如果降低到1.3GHz的话四核满载才0.7瓦而已。电压方面，Exynos 7420最高为1037毫伏，Exynos 5433则能达到1150毫伏，因此前者在更高频率下的功耗其实更低。
![](http://images.anandtech.com/doci/9330/a53-power-curve_575px.png)

# A57
大核心明显更耗电，2.1GHz满频率下单个核心最高就有1.6瓦，四核全速达到了5.5瓦。
当然，这比Exynos 5433 7.39瓦好得多了，Exynos 7420如果降低到与之相同的1.9GHz频率功耗才800mw，2.1GHz全速时也还不到1.3瓦。
![](http://images.anandtech.com/doci/9330/a57-power-curve_575px.png)

# A57/A53大小核切换
Exynos 5433里边如果A53部分的负载超过50％，就会启动A57部分，而反过来如果A57部分的负载低于25％，就会切回到A53部分。   
Exynos 7420的设置有很大不同，这两个切换点分别是46.7％、20.8％。之所以非整数，正是因为三星做了更精心的调校，确保这么做效率是最高的。   
Exynos 5433会尽量保留10％的冗余空间，Exynos 7420则会保留25％，意味着后者即使在负载还不太高的时候就会启动A57。Exynos 5433的大小核切换发生在900MHz之下，Exynos 7420则高于1100MHz。

# GPU
SoC处理器来说，如果功耗超过3-4W，是不可能一直维持最高频率的，只能被迫降频，关键就在于能支撑多久、会降低多少，骁龙810就输在了这两个指标上。
![](http://images.anandtech.com/doci/9330/gpu-freq-scaling_575px.png)