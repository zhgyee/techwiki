# BLE
现在低功耗蓝牙（BLE）连接都是建立在GATT（Generic Attribute Profile）协议之上。GATT是一个在蓝牙连接之上的发送和接收很短的数据段的通用规范，这些很短的数据段被称为属性（Attribute）。
## GATT
GATT的全名是Generic Attribute Profile，他定义两个BLE设备通过叫做Service和Characteristic的东西进行通信。GATT就是使用了ATT（Attribute Protocol）协议，ATT协议把Service，Characteristic遗迹对应的数据保存在一个查找表中，次查找表使用16bit ID作为每一项的索引。
一旦两个设备建立起了连接，GATT就开始起作用了，这也 意味着，你必需完成前面的GAP协议。这里需要说明的是，GATT连接，必须先经过GAP协议。实际上，我们在Android开发中，可以直接使用设备的MAC地址，发起连接，可以不经过扫描的步骤。这并不意味不需要经过GAP，实际上在芯片级别已经给你做好了，蓝牙芯片发起连接，总是先扫描设备，扫描到了才会发起连接。
GATT连接需要特别注意的是：GATT连接是独占的。也就是一个BLE外设同时只能被一个中心设备连接。一旦外设被连接，它就会马上停止广播，这样它就是一个BLE外设同时只能被一个中心设备连接。一旦外设被连接，它就会马上停止广播，这样它就对其他设备不可见了。当设备断开，它又开始广播。
中心设备和外设需要双向通信的话，唯一的方式就是建立GATT连接。


链接：https://www.jianshu.com/p/2b09498b84f2