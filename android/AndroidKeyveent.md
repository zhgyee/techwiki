# Introduction #

# Android input subsystem
```
linux kernel input subsystem   
                      |
                      V    read evdev driver   
android EventHub   
                      V
 Android InputReader   
                      |         Decodes the input events according to the device class and produces a stream of Android input events.
                      |         Linux input protocol event codes are translated into Android event codes according to the 
                      |          input device configuration,   keyboard layout files, and various mapping tables.   
                      V    
InputDispatcher forwards them to the appropriate window.
```
![Input subsystem](http://images.cnitblog.com/blog/563439/201311/06230834-a8145552ca56482c92b6179dff6bdb5c.png)
* Input Reader: 负责从硬件获取输入，转换成事件（Event), 并分发给Input Dispatcher.
* Input Dispatcher: 将Input Reader传送过来的Events 分发给合适的窗口，并监控ANR。
* Input Manager Service： 负责Input Reader 和 Input Dispatchor的创建，并提供Policy 用于Events的预处理。
* Window Manager Service：管理Input Manager 与 View（Window) 以及 ActivityManager 之间的通信。
* View and Activity：接收按键并处理。
* ActivityManager Service：ANR 处理。
[图解Android：Android的Event Input System](http://www.cnblogs.com/samchen2009/p/3368158.html)

# 输入设备配置文件(.idc文件）

idc(Input Device Configuration)为输入设备配置文件，它包含设备具体的配置属性，这些属性影响输入设备的行为。对于touch screen设备，总是需要一个idc文件来定义其行为。
       Android基于输入设备驱动汇报的事件类型和属性来检测和配置大部分输入设备的能力。然而有些分类是模棱两可的，如：多点触摸屏（multi-touch touch screen）和touch pad都支持EV_ABS事件类型和ABS_MT_POSITION_X和ABS_MT_POSTION_Y事件，然而这两类设备的使用是不同的，且不总是能自动判断。所以，需要另外的信息来指示设备上报的pressrue和size信息的真正含义。因为，触摸设备，特别是内嵌的touch screen，经常需要idc文件。[ref](http://blog.csdn.net/myarrow/article/details/7710617)
# Linux input subsystem
![input arch in linux kernel](http://images.cnitblog.com/blog/563439/201311/07225317-0771ad2449024d3eb90d1690710a676e.png)

# Linux input Event [ref](https://www.kernel.org/doc/Documentation/input/event-codes.txt)
## event type 
* EV_SYN:
  - Used as markers to separate events. Events may be separated in time or in
    space, such as with the multitouch protocol.

* EV_KEY:
  - Used to describe state changes of keyboards, buttons, or other key-like
    devices.

* EV_REL:
  - Used to describe relative axis value changes, e.g. moving the mouse 5 units
    to the left.

* EV_ABS:
  - Used to describe absolute axis value changes, e.g. describing the
    coordinates of a touch on a touchscreen.

## event code
* EV_SYN:
 - SYN_REPORT:Used to synchronize and separate events into packets of input data changes
    occurring at the same moment in time. For example, motion of a mouse may set
    the REL_X and REL_Y values for one motion, then emit a SYN_REPORT. The next
    motion will emit more REL_X and REL_Y values and send another SYN_REPORT.
* EV_KEY
 - BTN_TOUCH:
    BTN_TOUCH is used for touch contact.

# getevent #
## list event
```
getevent -l                                               
add device 1: /dev/input/event10
  name:     "m_mag_input"
add device 2: /dev/input/event16
  name:     "vtouchscreen"
add device 3: /dev/input/event2
  name:     "pswakeup"
add device 4: /dev/input/event1
  name:     "tmd27713"
add device 5: /dev/input/event0
  name:     "ewd500"
add device 6: /dev/input/event11
  name:     "gpio_keys.39"
add device 7: /dev/input/event9
  name:     "yas537_euler"
add device 8: /dev/input/event8
  name:     "yas537_cal"
add device 9: /dev/input/event7
  name:     "yas537_raw"
add device 10: /dev/input/event6
  name:     "magsensor_cal"
add device 11: /dev/input/event5
  name:     "INV_DMP"
add device 12: /dev/input/event4
  name:     "MPU6500"
```
## get touch event
```
getevent -l /dev/input/event0                             
EV_KEY       BTN_TOUCH            DOWN                
EV_ABS       ABS_X                00000033            
EV_ABS       ABS_Y                00000046            
EV_SYN       SYN_REPORT           00000000            
EV_ABS       ABS_X                0000003f            
EV_ABS       ABS_Y                00000042            
EV_SYN       SYN_REPORT           00000000            
EV_KEY       BTN_TOUCH            UP                  
EV_SYN       SYN_REPORT           00000000 
```
## tp motion
```
getevent -l /dev/input/event0                             
EV_KEY       BTN_TOUCH            DOWN                
EV_ABS       ABS_X                00000080            
EV_ABS       ABS_Y                00000048            
EV_SYN       SYN_REPORT           00000000            
EV_ABS       ABS_X                00000073            
EV_ABS       ABS_Y                00000053            
EV_SYN       SYN_REPORT           00000000            
EV_ABS       ABS_X                00000067            
EV_ABS       ABS_Y                00000057            
EV_SYN       SYN_REPORT           00000000            
EV_ABS       ABS_X                00000053            
EV_ABS       ABS_Y                00000059            
EV_SYN       SYN_REPORT           00000000            
EV_ABS       ABS_X                00000049            
EV_ABS       ABS_Y                0000005b            
EV_SYN       SYN_REPORT           00000000            
EV_ABS       ABS_X                00000031            
EV_SYN       SYN_REPORT           00000000            
EV_ABS       ABS_X                00000025            
EV_ABS       ABS_Y                00000056            
EV_SYN       SYN_REPORT           00000000            
EV_ABS       ABS_X                0000000a            
EV_ABS       ABS_Y                00000053            
EV_SYN       SYN_REPORT           00000000            
EV_ABS       ABS_X                00000001            
EV_ABS       ABS_Y                00000055            
EV_SYN       SYN_REPORT           00000000            
EV_KEY       BTN_TOUCH            UP                  
EV_SYN       SYN_REPORT           00000000 
```
# usefull key
|  name               | nb |
| ------------------- | ---|
| KEYCODE_DPAD_CENTER | 23 |
| KEYCODE_DPAD_UP     | 19 |
| KEYCODE_ENTER       | 66 |


# Reference #

http://thecodeartist.blogspot.com/2011/03/simulating-keyevents-on-android-device.html