IMS配置
=======================
*lishaoliang edit on 2015.9.21*


参见 [OpenSourceIMSCore](http://www.openimscore.org/documentation/installation-guide/)

##  服务器端

### 下载

> mkdir /opt/OpenIMSCore

> cd /opt/OpenIMSCore

*tips：请首先安装Subversion*

> mkdir FHoSS

> svn checkout https://svn.code.sf.net/p/openimscore/code/FHoSS/trunk FHoSS

> mkdir ser_ims

> svn checkout https://svn.code.sf.net/p/openimscore/code/ser_ims/trunk ser_ims


### 编译

编译容易出错，首先要安装一些**依赖**：

> sudo apt-get install libxml2 libxml2-dev libcurl4-gnutls-dev build-essential mysql-server mysql-client libmysql++-dev bind9 bison flex ant

（安装数据库时，牢记数据库的管理员密码）

> cd ser_imsspreadaob001

> make install-libs all

> cd ..


> cd FHoSS

> ant compile deploy

> cd ..


### 配置

####  配置domain
通过ifconfig找到本机IP，如：执行ser_ims/cfg/configurator.sh来输入domain和ip，一般为open-ims.test和本机IP(此脚本相当于批处理修改.cfg和.xml)192.168.22.246（一般为先用本地环路127.0.0.1来尝试连接，记得最后改成自己的ip）
`ser_ims/cfg/configurator.sh open-ims.test 192.168.199.200`
本机IP：192.168.199.200
执行ser_ims/cfg/configurator.sh来输入domain和ip，一般为open-ims.test和本机IP(此脚本相当于批处理修改.cfg和.xml)

####  配置DNS
* 备份，重要！

> sudo cp /etc/resolv.conf  /etc/resolvBAK.conf

* 修改网关：

> sudo vim /etc/resolv.conf，输入

nameserver 127.0.0.1

search open-ims.test

domain open-ims.test
注意：nameserver 127.0.0.1要覆盖原来的
* 增加DNS：

> sudo cp  /opt/OpenIMSCore/ser_ims/cfg/open-ims.dnszone  /etc/bind/

在/etc/bind/named.conf中添加

zone "open-ims.test" {

           type master;

           file "/etc/bind/open-ims.dnszone";

};


修改/opt/OpenIMSCore/ser_ims/cfg/open-ims.dnszone和/etc/bind/open-ims.dnszone里面的ip地址为本机IP，全部！

修改/opt/OpenIMSCore/FHoSS/deploy/DiameterPeerHSS.xml中bind的地址改为本机IP.（第一行改成：<?xml version="1.0" encoding="UTF-8"?>）

* 重启bind：

> sudo /etc/init.d/bind9 restart


* 测试域名解析是否成功：

> ping open-ims.test

####  导入测试数据库

> mysql -u root -p -h localhost < ser_ims/cfg/icscf.sql

> mysql -u root -p -h localhost < FHoSS/scripts/hss_db.sql

> mysql -u root -p -h localhost < FHoSS/scripts/userdata.sql

(遇到了userdata导入失败，可以使用MySQL workbench来对userdata.sql在第41行，最后增加“,0,0”,因为hss_db里定义的application_server是36个成员，这里只有34个)

####  配置IMSCore

将核心文件拷贝到/opt/OpenIMSCore/目录

> cd /opt/OpenIMSCore

> sudo cp ./ser_ims/cfg/*.cfg .

> sudo cp ./ser_ims/cfg/*.xml .

> sudo cp ./ser_ims/cfg/*.sh .

（简写：sudo cp ./ser_ims/cfg/*.cfg .;sudo cp ./ser_ims/cfg/*.xml .;sudo cp ./ser_ims/cfg/*.sh .）

1. 启动pcscf和scscf时遇到错误提示缺少lib_ser_cds.so库，则可将opt/OpenIMSCore/ser_ims/lib/cds中的这个文件拷贝到/usr/local/lib/ser(自己创建这个目录)里；
2. /etc/resolv.conf这个文件每次开机都会清空，导致每次开机的时候都要重新配置一遍该文件，可以使用sudo chattr +I /etc/resolv.conf命令来锁定该文件，这样每次开机后就不需修改此文件了。


### 启动IMS Core服务

> cd /opt/OpenIMSCore

* 分别在不同的终端启动如下三个组件：

> ./pcscf.sh

> ./icscf.sh

> ./scscf.sh

如果没有出现红字，那就说明成功了。

如果启动失败，检查.cfg和.xml文件里的服务器地址！

* 再启动一个终端，启动FHoSS

> ./fhoss.sh

* 在浏览器中输入http://localhost:8080/，进入后台管理。(普通用户hss/hss,管理员hssAdmin/hss)
(后台无法添加账户)
如果运行失败，很可能是JAVA_HOME配置错误，请在/etc/profile中增加

> export JAVA_HOME="/usr/lib/jvm/java-7-openjdk-amd64"

> export PATH="$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH"

> export CLASSPATH="$CLASSPATH:.:$JAVA_HOME/lib:$JAVA_HOME/jre/lib"


##  手机端配置

使用的imsdroid作为client端，参见[imsdroid quick start](https://code.google.com/p/imsdroid/wiki/Quick_Start)

打开imsdroid app，点击Options：

1. Identity配置

> Display Name: 随意

> Public Identity: sip:alice@open-ims.test (公开的标识，一般以sip:开头)
> Public Identity: sip:bob@open-ims.test (公开的标识，一般以sip:开头)

> Private Identity: alice@open-ims.test (私有的标识，账号前无前缀)
> Private Identity: bob@open-ims.test (私有的标识，账号前无前缀)

> Password: alice (alice和bobIMS（IP Multimedia Subsystem）是IP多媒体子系统，是一种全新的多媒体业务形式，它能够满足现在的终端客户更新颖、更多样化多媒体业务的需求。IMS即IP是由朗讯...账号为系统自带的测试账号)

> Realm: sip:open-ims.test

![Identity配置]（http://imsdroid.googlecode.com/svn/branches/1.0/screenshots/screen_identity.png）

2. Network配置

> Enable WiFi: 勾选

> Proxy-CSCF Host: 192.168.199.200 (本机IP)

> Proxy-CSCF Port: 4060

![Network配置]（http://imsdroid.googlecode.com/svn/branches/1.0/screenshots/screen_network.png）





Installing Android NDK r10e
Download Android NDK r10e into /home. This is needed only for the first time.

cd /home
wget http://dl.google.com/android/ndk/android-ndk-r10e-linux-x86_64.bin
./android-ndk-r10e-linux-x86_64.bin
(若提示权限问题导致不能安装，按以下步骤操作：
sudo chmod u+x android-ndk-r10e-linux-x86_64.bin
sudo ./android-ndk-r10e-linux-x86_64.bin
)
2. Set $NDK
You must set the $NDK variable:
export NDK=/home/android-ndk-r10e

3. Checking out Doubango code
Chekout Doubango v2.0 into /tmp:
cd /tmp
svn checkout https://doubango.googlecode.com/svn/branches/2.0/doubango doubango

4. Generate the configure file
The build system uses GNU AutoTools. The first step is to generate the configure file:
cd /tmp/doubango
./autogen.sh
(如果有提示一些不能识别的命令，先安装对应的包)

5. Building the code
Each script will build the code for all supported architectures.
./android_build.sh gpl
（保证环境变量NDK正确,并且导入NDK下的bin路径：
export NDK="/home/zhangbaowen/zhangbaowen/android-ndk-r10e"
export PATH="$PATH:$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin"
）

The binaries will be generated into /tmp/doubango/android-projects/output/gpl/imsdroid/libs/armeabi-v7a/.
