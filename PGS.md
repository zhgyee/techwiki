# Introduction #

Add your content here.


# Details #

Pgs字幕中每一个时刻的字幕可能包括多个显示区域Rect，每一个区域中可能包含多个组件Object

每一张pgs字幕分成多个数据包传输的，

包含调色板数据，图片数据，表示数据，显示数据等。
为了节省数据量，在一些特效字幕时可能只更新调色板数据，
图片数据依然使用上一张或前几张图片的内容。

数据的清除是通过发送一个空图片或者使用后一张图片将前一张图片进行清除。

表1 各数据分片包含的内容
| Palette Segment | 获得调色板数据:ID，Y,Cb,Cr生成调色板 |
|:----------------|:------------------------|
|Picture Segment  |获得多个Object，形成多张图片picture\_id；图片的宽高WxH；图片的数据长度；得到图片数据|
|Presentation Segment|得到显示的视频宽高；获得Object数目；需要显示的图片ID；得到每个Object的坐标x，y；得到表示信息|
|Display Segment  |将图片各元素按照显示要求组装           |

单张图片信息来源
|pts|display segment|
|:--|:--------------|
|duration|NULL           |
|x  |presentation segment|
|y  |presentation segment|
|w  |picture segment|
|h  |picture segment|
|data|picture segment|
|palette|palette segment|
|color\_count|palette segment|
|显示画布大小|               |
|video\_w|presentation segment|
|video\_h|presentation segment|
|图片数目|               |
|Object\_count|presentation segment|


完成一张图片的完整显示功能包括：
  1. 数据读取
  1. 数据解码
  1. 数据显示和擦除
  1. 数据拉伸和位置调整

Mpegts模块：M2ts的蓝光打包并未同步升级PAT的校验码，导致分成多个PMTSession的字幕信息无法被校验通过并成功拼接，造成部分m2ts文件发现不了pgs字幕轨道，部分m2ts文件只能发现少部分的字幕轨道，部分m2ts文件发现不了字幕轨道的描述信息

渐出渐入的效果

快速输出多张图片，通过调色板变化实现画面的渐入渐出效果
Pgs解码器：需要支持第二张图片使用第一张图片的picture数据，只更新调色板信息