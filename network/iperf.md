
1. 安装常用工具
Magic iPerf3_v1.0_apkpure.com.apk    
iperf-3.1.3-win64

2. 头盔安装apk，启动为server端：
```
iperf3 -s -i 1
```
3. dos窗口执行命令
```
iperf3 -c IP -b 50M -t 180
```
4. UDP发包
```
iperf -c ip地址 -u -b 99.75M -t xxx
```