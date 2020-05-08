#rtmp overview
rtmp是传输协议，在ffmpeg中实现在protocol级，类似于http/tcp等协议。
RTMP协议规定，播放一个流媒体有两个前提步骤：第一步，建立一个网络连接（NetConnection）；第二步，建立一个网络流（NetStream）。其中，网络连接代表服务器端应用程序和客户端之间基础的连通关系。网络流代表了发送多媒体数据的通道。服务器和客户端之间只能建立一个网络连接，但是基于该连接可以创建很多网络流。他们的关系如图所示：
![rtmp connections](http://img.blog.csdn.net/20130915111501437?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbGVpeGlhb2h1YTEwMjA=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

播放一个RTMP协议的流媒体需要经过以下几个步骤：

* 握手，RTMP连接都是以握手作为开始的
* 建立连接，建立连接阶段用于建立客户端与服务器之间的“网络连接”
* 建立流，建立流阶段用于建立客户端与服务器之间的“网络流”
* 播放，播放阶段用于传输视音频数据。
详细请参考: [ RTMP流媒体播放过程](http://blog.csdn.net/leixiaohua1020/article/details/11704355)

#rtmp ffmpeg commands

```
将文件当做直播推送至live服务器
ffmpeg -re -i localFile.mp4 -c copy -f flv rtmp://server/live/streamName
将直播媒体保存至本地文件
ffmpeg -i rtmp://server/live/streamName -c copy dump.flv  
将其中一个直播流，视频改用h264压缩，音频不变，送至另外一个直播服务流
ffmpeg -i rtmp://server/live/originalStream -c:a copy -c:v libx264 -vpre slow -f flv rtmp://server/live/h264Stream  

```
[ ffmpeg处理RTMP流媒体的命令大全](http://blog.csdn.net/leixiaohua1020/article/details/12029543)