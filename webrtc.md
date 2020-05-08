WebRTC
=================

# 官方指导 [webrtc native development]( http://www.webrtc.org/native-code/development )
# SkywaySDK
Skyway是docomo提供的一套sdk，本质上是webRTC的一个封装，功能上看website的介绍没啥区别。
Skyway的基本信息，可以在他们的官网上看到：
http://nttcom.github.io/skyway/en/docs/#Android
SkywaySDK使用的lib可以参考以下的website：
https://webrtc.org/native-code/android/
通过用下面的build script，取得最新的版本：
https://github.com/pristineio/webrtc-build-scripts
可以通过代码，看出skyway与Android Framework的调用关系。
# webrtc动态库生成
参考[gyp](gyp.md)
##  环境安装
### 下载工具Depot Tools
http://dev.chromium.org/developers/how-tos/install-depot-tools
> git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git ~/bin/
> export PATH=~/bin/depot_tools:$PATH
> source ~/.bashrc
### 源代码
在终端切换到需要下载代码的workspace,执行
> mkdir webrtc-checkout
> cd webrtc-checkout
> fetch webrtc_android
如果下载失败,建议使用代理或者VPN等方法。下载下来大概有17G。
### 依赖
编译会依赖很多工具包,执行下面的脚本,可以下载缺失的工具:
> ./build/install-build-deps.sh
下载Android SDK和NDK,下载过程略,更新环境变量:
在/etc/profile文件中增加(以实际目录为准,供参考):
export JAVA_HOME="/usr/lib/jvm/java-7-openjdk-amd64"
export ANDROID_NDK_ROOT="/home/user/Android/android-ndk-r10e"
export ANDROID_SDK_ROOT="/home/user/Android/Sdk"
export PATH="$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/bin"
export PATH="$PATH:$ANDROID_SDK_ROOT/platform-tools/:$ANDROID_SDK_ROOT/tools"
export PATH="$PATH:$ANDROID_NDK_ROOT/prebuilt/linux-x86_64/bin"
export CLASSPATH="$CLASSPATH:.:$JAVA_HOME/lib:$JAVA_HOME/jre/lib"
在.bashrc配置文件中增加:
export GYP_DEFINES="OS=android"
重启或者执行source来使其生效。
### 编译
切换到src目录,首次建议全编译,执行
> ninja -C out/Debug/
编译时,会收到删除部分重复代码的建议,按照说明执行(仅首次运行)
> python setup_links.py
以后如果需要编译某个模块,如AppRTC,可以执行:
> ninja -C out/Debug/ AppRTCDemo
每次编译前,需要执行> gclient runhooks
*此条命令是生成适合当前编译平台的编译工程和脚本*
另外,建议网络允许情况下首先执行
> gclient sync
*此条命令会同步最新代码,并且同时会hooks,耗时较长*
##  测试模块
### WebRTC Engine Demo
位置:src/webrtc/examples/android/media_demo
模块:org.webrtc.webrtcdemo
此模块用于测试RTC的交互,但目前测试有问题,无法连通。
### AppRTC Demo
位置:src/webrtc/examples/androidapp
模块:org.appspot.apprtc
此app可以通过默认的room server:[apprtc]( https://apprtc.appspot.com )来创建room,手机端可以输入房间号,与浏览器进行音视频交
互。
####  操作步骤
1. 浏览器打开[apprtc]( https://apprtc.appspot.com ),输入一个房间号,也可以随机生成;
2. 手机端打开AppRTC,在room name处输入刚才的房间号;
3. 点击OK,在Room names列表中,点击需要连接的房间号,然后点击拨号图标;
4. 连接成功,会在浏览器上看到手机的camera的实时预览,并能听到音频传输。
