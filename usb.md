# USB传输的4种模式
* BULK：块数据传输 追求数据完整性，CRC校验，故该种传输方式，虽然可以做大数据的传输，但是并不适合实时传输；
* Interrupt：中断传输 也是实时传输，对数据准确性有一定保证；
* ISO：同步传输  追求实时性，无校验，允许有一定的误码率，一般用于实时传输比如视频会议，音频等；
* control：控制数据传输

# Why isn't USB interrupt driven
This is a great question. The polling that you are referring to is not in the OS though, it is in the USB host controller (the PCI/PCI-X/PCI-e device that lets you plug-in USB devices). Thus, a polling mechanism doesn't cost any CPU cycles which is what you would care the most.    
 
In addition, the USB host controllers with cooperation from the OS support the so called selective suspend technology. This allows most of the peripherals, hubs and the controller to enter into low power state when idle and not in use. Thus no power/cycles are wasted there as well.    

Depending on your host controller, your CPU may need to do some polling.  UHCI requires polling all root ports for connect / disconnect events.  This occurs after a number of milliseconds rather than microseconds though.  Typically when you hear of polling in USB, however, it means that you submit a request block, for example by linking it into a queue read by hardware, and then you get an interrupt when the request completes.

* Poll
* request block queue

# OTG device support
list usb device bus id `lsusb `    
 usb device can be found under `/dev/bus/usb/busid`    
/dev/bus/usb/busid need udb group to read or write    
user apps can using libusb to read/write device    
## android OTG支持
Android清单要求

在使用USB主机模式API工作之前，你需要把以下介绍的内容添加到你的应用程序清单中：

1. 因为不是所有的Android设备都保证支持USB主机模式，所以要在你的应用程序声明中包含元素，以声明你的应用程序要使用android.hardware.usb.host功能。

2. 把应用程序的最小SDK设置为API Level 12或更高的版本。在较早的API版本中不存在USB主机模式API。

3. 如果你希望你的应用程序能够获得接入USB设备时的通知，那么还要在你的主Activity中指定用android.hardware.usb.action.USB_DEVICE_ATTACHED类型的Intent来配对的和元素。元素要指向一个外部的XML资源文件，该文件声明了希望检测的设备的识别信息。

在这个XML资源文件中，要用元素来声明你想要过滤的USB设备。以下列出了元素的属性。通常，使用vendor-id和product-id来指定你所希望过滤的特定的设备，并且使用class、subclass和protocol来指定你所希望过滤的USB设备组，如大容量存储设备或数码相机。你可以不指定任何属性，或所有全部属性。不指定任何属性，就会跟所有USB设备匹配，如果应用程序需要，就可以这样做：

A. vendor-id

B. product-id

C. class

D. subclass

E. protocol（设备或接口）

# UART ttyUSB ttyACM
* UARTs present on your computer (if any) will be named /dev/ttyS0 and /dev/ttyS1 
* Similarly, the devices offering UART-over-USB functionalities are named /dev/ttyUSB0, /dev/ttyUSB1, and so on, even though they are in fact using distinct device drivers.
* abstract control model or ACM. When developping on a USB-enabled embedded microcontroller that needs to exchange data with a computer over USB, it is tempting to use a standardized way of communication which is well supported by virtually every operating system. This is why most people choose to implement CDC/PSTN with ACM.

# libusb 
I am trying to communicate with USB device from Android-based smartphone via OTG. I was able to communicate with my device using Android USB Host API. **The problem of USB Host API solution is performance** (**single bulk transfer bounded by 16384 bytes**).

The libusb can perform larger requests and now I am trying to integrate it using Android NDK. I succeeded to compile libusb sources for Android and even initUSB(), but libusb_open(dev, &dev_handle) returns -3 (Access denied).

https://github.com/kuldeepdhaka/libusb/tree/android-open2

How To for Android
==================

1. Search for the UsbDevice [1] you are interested in.
2. Extract the usbfs path [2] from the UsbDevice.
3. Build a libbox0_device from the path
    using libusb_get_device2(context, path) [3]
4. open the UsbDevice [4], you will get UsbDeviceConnection [5].
5. from the UsbDeviceConnection, extract the fd[6]
6. now, from the fd and the previously
    created libusb_device, build a libusb_device_handle
    by calling libusb_get_device2(dev, handle, fd)[7].
7. and that all you need.

* [1] http://developer.android.com/reference/android/hardware/usb/UsbDevice.html
* [2] http://developer.android.com/reference/android/hardware/usb/UsbDevice.html#getDeviceName%28%29
* [3] https://github.com/kuldeepdhaka/libusb/blob/android-open2/libusb/core.c#L1492
* [4] http://developer.android.com/reference/android/hardware/usb/UsbManager.html#openDevice%28android.hardware.usb.UsbDevice%29
* [5] http://developer.android.com/reference/android/hardware/usb/UsbDeviceConnection.html
* [6] http://developer.android.com/reference/android/hardware/usb/UsbDeviceConnection.html#getFileDescriptor%28%29
* [7] https://github.com/kuldeepdhaka/libusb/blob/android-open2/libusb/core.c#L1267

## libusb数据传输接口
* 块传输 这部分允许应用从数据块管道发送和接收数据。
```
//写入一块数据到端点ep，返回写入成功字节数，负数失败。
int usb_bulk_write(usb_dev_handle *dev, int ep, char *bytes, int size, int timeout);
//读取一块数据，从端点ep，返回读取成功字节数，负数失败。
int usb_bulk_read(usb_dev_handle *dev, int ep, char *bytes, int size, int timeout);
```
* 中断传输
这组函数允许应用发送和接收数据通过中断管道。
```
//执行对端点ep的中断写入，返回实际写入字节数，负数失败。
int usb_interrupt_write(usb_dev_handle *dev, int ep, char *bytes, int size, int timeout);
//执行对中断端点ep的读取，返回实际读取字节数，负数失败。
int usb_interrupt_read(usb_dev_handle *dev, int ep, char *bytes, int size, int timeout);
```
实际的读写还是通过ioctrl提交到内核来完成。

# usb vs iic
外设数据通过usb传输还是通过spi或iic传输的差别是：

usb一次中断将数据发送出去，iic则需要几次中断来完成传输，在数据量小时，基本无什么差别，只有数据量大时，usb块传输的优势才能体现出来。

一台vr主机分别连接usb gyro和iic gyro，并且两类gyro都以500hz的频率发送数据，从实验结果可以看出usb的方式，中断次数会减小4.4%左右，而CPU使用率只下降1%左右，中断占用率仅下降0.01%。

usb + iic的mpstat统计结果
```
08:25:08     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle
08:25:08     all    5.07    0.06    3.60    0.57    0.03    0.02    0.00    0.00   90.65
08:25:08       0    0.01    0.00    3.95    0.17    0.22    0.08    0.00    0.00   95.58
08:25:08       1    1.98    0.00    6.45    0.35    0.00    0.03    0.00    0.00   91.19
08:25:08       2    2.99    0.03    2.52    0.24    0.00    0.01    0.00    0.00   94.21
08:25:08       3    1.34    0.00    1.88    0.29    0.00    0.03    0.00    0.00   96.46
08:25:08       4    5.46    0.10    2.74    0.86    0.00    0.00    0.00    0.00   90.85
08:25:08       5    4.42    0.06    6.11    0.97    0.01    0.00    0.00    0.00   88.42
08:25:08       6   14.39    0.15    2.79    0.76    0.00    0.00    0.00    0.00   81.92
08:25:08       7    9.28    0.13    2.47    0.90    0.00    0.00    0.00    0.00   87.22

08:25:08     CPU    intr/s
08:25:08     all  26116.17
08:25:08       0  14367.46
08:25:08       1   3252.63
08:25:08       2   1365.98
08:25:08       3    939.87
08:25:08       4   1854.98
08:25:08       5   1599.86
08:25:08       6    835.75
08:25:08       7    824.08

08:25:08     CPU      HI/s   TIMER/s  NET_TX/s  NET_RX/s   BLOCK/s BLOCK_IOPOLL/s TASKLET/s SCHED/s HRTIMER/s  RCU/s
08:25:08       0      0.00    110.25      0.00      0.19      0.00      0.00    172.20     13.29      4.96    101.07
08:25:08       1      0.00    737.42      0.00      1.18      0.00      0.00      0.00     51.59      3.24    463.81
08:25:08       2      0.00    574.30      0.00      0.27      0.00      0.00      0.00     48.35      0.90    371.34
08:25:08       3      0.00    542.10      0.00      2.96      0.00      0.00      0.00     64.64      0.53    348.85
08:25:08       4      0.00    450.26      0.00      0.01      0.00      0.00      0.01    176.01      2.40    277.64
08:25:08       5      0.00    252.24      0.00      0.00      0.00      0.00      0.00     89.05      2.69    170.06
08:25:08       6      0.00    284.48      0.00      0.00      0.00      0.00      0.00     74.69      1.51    171.50
08:25:08       7      0.00    229.98      0.00      0.01      0.00      0.00      0.00     68.65      1.14    158.08
```
纯usb时mpstat的统计结果
```
08:26:44     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle
08:26:44     all    4.22    0.05    3.26    0.46    0.02    0.02    0.00    0.00   91.98
08:26:44       0    0.00    0.00    3.29    0.14    0.19    0.06    0.00    0.00   96.32
08:26:44       1    1.76    0.00    6.56    0.28    0.00    0.02    0.00    0.00   91.38
08:26:44       2    2.52    0.02    2.29    0.19    0.00    0.01    0.00    0.00   94.97
08:26:44       3    1.20    0.00    1.73    0.23    0.00    0.03    0.00    0.00   96.82
08:26:44       4    4.54    0.08    2.42    0.68    0.00    0.00    0.00    0.00   92.28
08:26:44       5    3.76    0.04    5.10    0.77    0.01    0.00    0.00    0.00   90.31
08:26:44       6   11.78    0.12    2.56    0.60    0.00    0.00    0.00    0.00   84.95
08:26:44       7    7.64    0.10    2.26    0.71    0.00    0.00    0.00    0.00   89.28

08:26:44     CPU    intr/s
08:26:44     all  25007.31
08:26:44       0  14008.11
08:26:44       1   3239.76
08:26:44       2   1218.98
08:26:44       3    851.92
08:26:44       4   1642.35
08:26:44       5   1426.52
08:26:44       6    820.43
08:26:44       7    809.30

08:26:44     CPU      HI/s   TIMER/s  NET_TX/s  NET_RX/s   BLOCK/s BLOCK_IOPOLL/s TASKLET/s SCHED/s HRTIMER/s  RCU/s
08:26:44       0      0.00     97.89      0.00      0.15      0.00      0.00    146.97     12.57      4.12     89.99
08:26:44       1      0.00    723.24      0.00      0.94      0.00      0.00      0.00     47.12      3.33    454.59
08:26:44       2      0.00    548.30      0.00      0.21      0.00      0.00      0.00     47.54      0.85    360.55
08:26:44       3      0.00    503.22      0.00      2.90      0.00      0.00      0.00     58.93      0.52    324.27
08:26:44       4      0.00    401.73      0.00      0.00      0.00      0.00      0.01    166.24      2.33    256.62
08:26:44       5      0.00    228.41      0.00      0.00      0.00      0.00      0.00     84.38      2.42    153.65
08:26:44       6      0.00    254.12      0.00      0.00      0.00      0.00      0.00     70.44      1.47    155.97
08:26:44       7      0.00    207.50      0.00      0.00      0.00      0.00      0.00     65.16      1.24    143.12
```