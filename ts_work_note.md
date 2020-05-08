#mmvideo webex
每天下午4:30
会议号： 998 323 305
会议密码： 该会议不需要密码。
到时间后，由此处开始或加入 WebEx 会议：
https://shwebex.spreadtrum.com/orion/joinmeeting.do?MK=998323305
访问信息
会议号： 998 323 305
会议密码： 该会议不需要密码。
音频连接
公司内部请拨打 (588) 3799
公司外部请拨打 + 86 21 20360600 Ext 3799
#tcpdump
adb shell tcpdump -p -s 0 -w /sdcard/capture.pcap
# media test resource of spreadtrum
http://111.205.161.55:8082/


#虚拟按键显示方法：
adb pull /system/build.prop ./
将build.prop最后一行添加：emu.hw.mainkeys=0
push build.prop后重启
#webkit
```
adb root
adb remount
adb shell stop
adb shell rm -rf /system/app/webview /system/app/WebViewGoogle
adb shell start
adb install -r -d out/Release/apks/SystemWebView.apk
```
## webkit server
bluepine@10.101.16.102
81215225
source/spreadtrum_chromium
scp bluepine@10.101.16.102:/home/bluepine/source/spreadtrum_chromium/src/out/Release/apks/SystemWebView.apk .

#webrtc
./video_replay --input_file /sdcard/capture.pcap  --payload_type 96 --ssrc 6132 
logcat -c & ./video_engine --input_file netdata.pcap --ssrc 1804781290 -payload_type 100
logcat -c & ./video_engine --input_file /sdcard/capture.pcap --ssrc 3043922700 -payload_type 100
# account info & useful links
##  qcom
 http://192.168.8.24:8080/share/page/site/Qualcomm/documentlibrary#filter=path%7C%2FLibrary%2F8909-8208%2FSW%7C&page=1 
 baixy/baixy
## compile server
scp bluepine@10.101.16.102:/home/bluepine/source/ts_aosp/
81215225
scp bluepine@10.101.16.102:/home/bluepine/source/ts_aosp/out/target/product/generic/system/app/webview/webview.apk .
scp bluepine@10.101.16.102:/home/bluepine/source/ts_aosp/out/target/product/generic/system/lib/libwebviewchromium.so .
## imsserver虚拟机
帐号：imsserver
密码：imsserver
虚拟机mysql
帐号：root
密码：imsserver
## 翻墙路由器：
目前IT新建立了一个可以直接翻墙的SSID：Testing-vpn
有需要直接翻墙测试的项目，请在svn上更新http://192.168.7.3/svn/cdsvn/成都设备/Testing网络接入

http://192.168.199.1
admin：spreadaob001
vpn:pptp 174.139.85.235 usename:bluepine passwd:BBth2nd6rs0ft
1 67.198.129.62 美国  100M宽带,可视频,禁下载  PPTP / L2TP 正常
2 199.244.112.204 美国  100M宽带,可视频,禁下载  PPTP / L2TP 正常
3 67.198.158.158  美国  100M宽带,可视频,禁下载  PPTP / L2TP 正常
4 98.126.185.214  美国  100M宽带,可视频,禁下载  PPTP / L2TP 正常
5 174.139.85.235  美国  100M宽带,可视频,禁下载  PPTP / L2TP 正常
6 98.126.33.53  美国  100M宽带,可视频,禁下载  PPTP / L2TP 正常
7 98.126.7.132  美国  100M宽带,可视频,禁下载  PPTP / L2TP 正常
8 199.241.147.123 美国  100M宽带,可视频,禁下载  PPTP / L2TP 正常
9 199.241.145.236 美国  100M宽带,可视频,禁下载  PPTP / L2TP 正常
10  98.126.191.69 美国  100M宽带,可视频,禁下载  PPTP / L2TP 正常
11  67.198.140.202  美国  100M宽带,可视频,禁下载  PPTP / L2TP 正常
12  192.173.153.46  美国  100M宽带,可视频,禁下载  PPTP / L2TP 正常
## 翻墙wifi
SPRD_AOB_WIFI/SPRD_AOBABC
## enginering mode
*#*#83781#*#*
## jekins/converity/hudson等展讯服务器的账号
Spreadst
Pa55wd@123
##  jenkins server
http://10.0.1.163:8080/jenkins/  

##  Opengrok
http://10.101.16.200:8088/source/

##  DAPS wiki
http://10.101.16.200/mediawiki/index.php?title=%E9%A6%96%E9%A1%B5

##  DAPS svn server
http://10.101.16.200/svn/DAPS

##  thundersoft svn
http://192.168.7.3/svn/cdsvn

##  remindme
http://c.thundersoft.com/tsefforts/timelog

##  tonghu
## # gerrit code review
http://review.source.spreadtrum.com/gerrit/#/
tonghu_aob
tonghu
## #spread mail
 tonghu@spreadaob.com，TSspreadaob0505   http://106.2.179.11/extmail/cgi/index.cgi
 http://mail.spreadaob.com/extmail/cgi/index.cgi
## # spread bugzilla
tonghu@spreadaob.com
pwd：tonghu123
##  bugzilla
 http://bugzilla.spreadtrum.com/bugzilla
## lisl
## #Bugzilla信息：
user:lisl@spreadaob.com
pwd:lislaob

user:chenyc@spreadaob.com
pwd:spread123

user:zhangyi@spreadaob.com
pwd:spread123
## # gerrit信息：
lisl_aob/lisl
chenyc_aob/chenyc
zhangyi_aob/zhangyi


##  邮箱：
lisl@spreadaob.com/Spreadaob1127
chenyc@spreadaob.com/TSspreadaob0505

##  cts-wifi account info
TS-tset
spreadaob123

# android env setup

##  OpenJDK-7安装步骤：
```
sudo apt-get install openjdk-7-jre-lib
sudo apt-get install openjdk-7-jdk
```
##  配置jdk：
修改跟目录下.bashrc文件
gedit .bashrc
修改JAVA_HOME指向
```
export JAVA_HOME=/home/xiazg0712/jdk1.6.0_24
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
```
##  adb connect

adb shell提示“error: insufficient permissions for device”解决办法：
1. 在.android/adb_usb.ini文件中加上0x1782
2. 添加/etc/udev/rules.d/51-android.rules文件，内容为（SUBSYSTEM=="usb", ATTRS{idVendor}=="1782", ATTRS{idProduct}=="5d24",MODE="0666"）
3. sudo chmod a+x 51-android.rules

# review comments format

1).[Reader/Recoder] Reader: zhangyi 
2).[Review中的提问记录] 
  (1)格式逐行检查，代码中不允许存在Tab键 PASS 
  (2)修改逻辑是否清
  晰？ YES 
  (3)影响范围多大？相关周边测试是否进行？ NO EFFECT , YES 
  (4)是否重构了原有代码？ NO 
  (5)上下文理解是否清楚？YES 
  (6)逐行check理解？YES 
  (7)测试观点的review意见？ Follow the bug test steps 
3).[Bug 理解] YES 
4).[Review出来的问题] N／A 
5).[第1次Review后结果] PASS
# root cause 格式
```
[1.Root Cause        ]:点击Gallery小部件时，界面会先跳转到WidgetClickHandler，再到GalleryActivity，就导致了闪烁的现象

[2.Resolution        ]:设置WidgetClickHandler的style为Theme.NoDisplay，让其不显示

[3.Testing Suggestion]:follow bug steps

[4.Probability from RD]:偶现，概率很高

[5.Impact for customer]: 如果不修改，打开桌面的gallery小部件，出现闪烁，用户体验不好

[6.Modification scope]:packages/apps/Gallery2/AndroidManifest.xml

[7.Regression Failed Reason](Optional):

[8.Process Analysis Review](Optional):

[9.SideEffect](Optional):none

[10.Self Test Items]:<7731g><follow bug steps,test 10 times,pass><view picture from widget,no flash,pass>
```
#转组格式
[CD_WEBKIT][15/11/26][-> FW_AUDIO]
请Audio Framework同事分析，如果流转有误，请帮忙转给相应负责人。

# commit log格式

```
Bug #461850 [7731G][Monkey]ANR in com.android.music:Input dispatching timed out 

[bug number  ]461850
[root cause  ]monkey了过多启动MediaPlaybackActivity的实例,在finish过程,出现了不能全部finish的问题,导致PlaylistBrowserActivity一直不能获取焦点,响应不了事件,所以出现ANR.这种多实例导致的问题，实际过程中不会存在这种情况。
[changes     ]在MediaPlaybackActivity启动时判断如果是monkey，则不使用多实例。
[side effects]no
[self test   ]<7731g><monkey test,can't self-test><monkey test>
[change_type ] feature_bugfix
[whether AOB ]yes
[reviewers   ]zhangyi
```

# merge rules 
* 现在都要求代码先提交到主干,然后 cherry pick到具体分支
* 如还有其它分支，owner自己根据问题是否共性判断。
* sprdroid5.1_tshark_15a问题合入主干sprdroid5.1_trunk
* sprdroid5.1_sharkl_15c_mp 再过项目节点，三级或不紧急问题，先不着急合入
* sprdroid5.1_sharkl_15c_mp大规模量产分支,合入原则： SharkL#7/Volte/GlobalV1.1.0项目将 在15C分支上维护，维护的工程问题均 需合入15C分支。
* sprdroid5.1_sharkl_15c_mp_cmcc 跟CMCC分支没有关系，建议合入15C_MP
* sprdroid5.1_sharkl_15b_mp 建议合入15C_MP
* sprdroid5.1_tshark_15a 建议合入trunk


# SCM commands
[1.Root Cause        ]:For non-offloaded audio, do not deliver audio data too soon after stop when in paused mode.  Otherwise the audio MixerThread will keep the track playing, instead of inactivating the track.

[2.Resolution        ]:Do not deliver audio too soon after stop

[3.Testing Suggestion]:1.拖动一首歌到末尾,进度条返回起点,验证不会有声音出来
2.关闭重复播放，播放音乐完毕后，验证音乐不会重头播放2-3S然后停止

[4.Probability from RD]:必现

[5.Impact for customer]: 1.如果合入，使用自带音乐播放器播放或者拖动到未尾，结束后不会有声音出来。
2.如果不合入，使用自带音乐播放器播放或者拖动到未尾，结束后会有开头声音出来，影响正常功能使用。

[6.Modification scope]:media/libmediaplayerservice/nuplayer/NuPlayerRenderer.cpp
media/libmediaplayerservice/nuplayer/NuPlayerRenderer.h

[7.Self Test Items ]:1.拖动一首歌到末尾,进度条返回起点,自测试不会有声音出来
2.关闭重复播放，播放音乐完毕后，自测试音乐不会重头播放2-3S然后停止

git push ssh://zhangyi_aob@10.0.0.160:29418/platform/frameworks/av HEAD:refs/for/sprdroid6.0_trunk
##  sprd trunck branch

```
repo init -u gitaob@10.101.16.200:android/platform/manifest -b sprdroid5.1_trunk
repo init -u gitaob@10.101.16.200:android/platform/manifest -b sprdroid5.1_trunk_pike_full
repo init -u gitaob@10.101.16.200:android/platform/manifest -b sprdroid6.0_prime
repo sync

sprdroid6.0_trunk
repo init -u gitaob@10.101.16.200:android/platform/manifest -b  sprdroid6.0_trunk
repo sync -c --no-tags

chromium
git clone gitaob@10.101.16.200:android/chromium.git
```
##  Jiao图项目新分支已拉，具体信息更新到图表中。

AP 量产分支          11/24 基于W47.5 拉出MP分支：sprdroid5.1_jiaotu_15e

AP 量产分支Daily Build(单安卓)        http://10.0.1.167:8080/jenkins/job/sprdroid5.1_jiaotu_15e/

AP 量产分支Daily Build(单安卓)verify      sprdroid5.1_jiaotu_15e:jiaotu_tc_global-userdebug-native

##  切换到需要提交的分支
```
git checkout -b 15a_phase2 --track korg/sprdroid5.1_tshark_15a_phase2 
git pull
```

##  代码提交
'''
git push ssh://zhangyi_aob@review.source.spreadtrum.com:29418/platform/frameworks/webview HEAD:refs/for/sprdroid5.1_trunk_pike_full
'''
##  mount smb server
`sudo mount -o domain=spreadtrum,username=Spreadst,password=Pa55wd@123  //10.0.1.110/Hudson/ShareData/CSDataRelease ~/spreadtrum/hudson`
##  android m source code
在自己的主目录（HOME目录）下的.gitconfig文件中（如果没有就建一个）加入下面两行：
```
[url "git://192.168.9.83/android.googlesource.com/"]
     insteadOf = https://android.googlesource.com/
```
建立一个新目录，进入里面，执行下面的命令下载代码：
```
repo init -u git://192.168.9.83/android.googlesource.com/platform/manifest.git -b android-6.0.0_r1
repo sync
```
详细的分支信息可以在CGIT服务器上查看：
http://192.168.9.83/cgi-bin/cgit.cgi/android.googlesource.com/platform/manifest.git
 
也可以直接在CGIT服务器上查看Android代码：
http://192.168.9.83/cgi-bin/cgit.cgi/android.googlesource.com/
 
更详细的下载信息请参考SCM的WiKi：
http://192.168.9.142/mediawiki/index.php/代码镜像下载一览
看里面的第一段：Google镜像

# install virtual box
```
sudo apt-get install linux-headers-generic build-essential dkms
sudo apt-get remove --purge virtualbox-dkms
sudo apt-get install virtualbox-dkms
```
# spread contact info

花文美 Tel :   +86 21-2036-0600 ext. 3542
余家旺+86 21-2036-0600 ext. 2283 13167015280
tianqichen:+86 21-2036-0600 ext. 2280
jerry gu:+86 21-2036-0600 ext. 6194
Video相关同事联系方式：
程勇：  902120360600 - 1898
陆健：  - 1941
阮文强：- 1523
胡文安：- 6245
解码器：
罗小伟：- 1824
vincent:1879
李杰 gerry.li

TEL: 021-20360600-1372 (588 - 1372)

MP: 13585820260

测试：
吉玲：  - 6809
王翠营：902284841399 - 1739

TJ:022-84841399
# spread branch FO
* sprdroid5.1_tshark_15a_phase2/sprdroid5.1_sharkl_15c_mp     renlong
* sprdroid5.1_tshark_15a  jerry gu
* 
#展讯芯片相关
## omx实现
avcdec中，onQueueFilled是主要的解码线程，从dec_in中取es数据，送解码器解码后，在dec_out中输出信息
ALOGV("%s, %d, dec_in.dataLen: %d, mPicId: %d", __FUNCTION__, __LINE__, dec_in.dataLen, mPicId);//输入
ALOGI("%s, %d, dec_out.pBufferHeader: %p, dec_out.mPicId: %d, dec_out.pts: %lld", __FUNCTION__, __LINE__, dec_out.pBufferHeader, dec_out.mPicId, dec_out.pts);
dump_bs( mPbuf_stream_v, dec_in.dataLen);//dumpes数据
dump_yuv(data, mPictureSize);//dump yuv数据
```
kWhatEmptyThisBuffer:-->
kWhatFillThisBuffer:-->
  SPRDAVCDecoder::onQueueFilled->
    MMDecRet decRet = (*mH264DecDecode)(mHandle, &dec_in,&dec_out);
    notifyEmptyBufferDone(inHeader);
    drainOneOutputBuffer
        notifyFillBufferDone(outHeader);
```
## 解码花屏
img_ptr->frame_num != img_ptr->pre_frame_num，确实有丢帧存在，所以出现了解码花屏，目前测试还没有复现，没有dump码流，从log中也未看出NuPlayer出现异常，
麻烦网络同事再确认一下是否存在丢帧问题，tcp传输是否异常，谢谢。
## T8改单核的方法
```
adb shell
echo 0 > /sys/devices/system/cpu/cpu1/online
echo 0 > /sys/devices/system/cpu/cpu2/online
echo 0 > /sys/devices/system/cpu/cpu3/online
echo 0 > /sys/devices/system/cpu/cpu4/online
echo 0 > /sys/devices/system/cpu/cpu5/online
echo 0 > /sys/devices/system/cpu/cpu6/online
echo 0 > /sys/devices/system/cpu/cpu7/online
```
改完后用cat /proc/cpuinfo或cat /proc/interrupts确认下，只有cpu0
## GPU
MTK和我们一样，针对车子的光照效果做了特殊处理
根据从MTK手机导出的shader，做类似处理
根本原因是Mali400硬件限制，支持不了超过一定个数的寄存器操作的shader
## GL error leak issue
// glFinish() need dequeue buffer, and it is not 100% success   373
// It generates gl error sometimes, this error will be there374
// until glGetError called. Call GLUtils::dumpGLErrors to clean 375
// the error in case it leaks to other functions376
GLUtils::dumpGLErrors();
#工程模式
*#*#83781#*#*
## GDB调试chromium webview
1  重新编译debug版本：ninja -C out/Debug system_webview_apk
2  安装该版本，打开浏览器。
3  src目录下运行命令: build/android/adb_gdb --package-name=com.android.browser --debug 
##  gpu memory
通过对比UCWEB浏览器，使用adb shell cat d/mali0/gpu_memory来对比百度图片的现象，webkit中mali内存会不断的增长，达到300多M，而UCWEB在mali内存达到200M左右后，会降低到30多M再增加
所以UCWEB应该有不断的申请释放cache的情况，而webkit可能cache了过多的memory，导致mali分不到内存
##  audio device dump
please use the latest version binary : 
1. adb shell
2. su
3. 
4.echo dumpmusic=1 > /dev/pipe/mmi.audio.ctrl
5. reproduce the issue
6. adb pull /data/local/media/audio_dumpmusic.pcm ./
7. attach the audio_dumpmusic.pcm, 

we will check the pcm data on PC and to check what kind of noise, thank you!

#修改CPU频率的方法如下
adb shell
su
cd /sys/devices/system/cpu/cpu0/cpufreq
查看当前可选频率：
cat scaling_available_frequencies
能看到当前可运行频率：
​1300000 1200000 1000000 768000
修改cpu频率
echo 1300000 > scaling_min_freq
echo 1300000 > scaling_max_freq
确认是否修改成功：
cat scaling_cur_freq
#CP的log可以直接抓取在Slog里面
建议测试能够复测此问题，务必抓取AP/CP log，CP的log可以直接抓取在Slog里面，以便部分丢失。具体操作：工程模式->Slog settings->Modem log settings->Log输出方式设置->SD抓取


1/28 morning late