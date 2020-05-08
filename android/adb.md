# 修改adb端口
```
adb -P 7569 start-server
```
# android adb event
```
adb shell input swipe 500 500 0 0

```

# adb over tcp
No root required!
```
//Connect the device via USB and make sure debugging is working.
adb tcpip 5555
//find the IP address with adb shell netcfg or adb shell ifconfig with 6.0 and higher
adb connect <DEVICE_IP_ADDRESS>:5555
//Disconnect USB and proceed with wireless debugging.
adb -s <DEVICE_IP_ADDRESS>:5555 usb to switch back when done.

```
# adb 设备发现
1. 在.android/adb_usb.ini文件中加上0x1782
2. 添加/etc/udev/rules.d/51-android.rules文件，内容为
 `SUBSYSTEM=="usb", ATTRS{idVendor}=="2e44", MODE="0666", GROUP="plugdev"`
3. sudo chmod a+x 51-android.rules
4. sudo service udev restart
5. adb kill-server

Note: idVendor/idProduct get from lsusb

[ref](http://blog.csdn.net/test162543/article/details/8523466)

# 端口占用问题 #

有时遇到占用5357端口的进程杀不掉，通过`netstat -nao|findstr "5037"`查看哪个进程占用此端口，一般是系统服务LogAndAlerts，
可以通过修改环境变量`ANDROID_ADB_SERVER_PORT`来修改adb的端口号

#send broadcast intent
`adb shell am broadcast -a test_dialog`

`adb shell am broadcast -a com.android.test --es test_string "this is test string" --ei test_int 100 --ez test_boolean true`

说明：test_string为key，"this is test string"is value，分别为String类型，int类型，boolean类型

#am
`adb shell am start -n com.idsee.ar/.activity.HomeActivity -e "video_path" "/sdcard/Movies/test-360ud.mp4" --ei "video_type" 7`