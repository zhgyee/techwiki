# 按键
device/samsung/hmd8895/overlay/frameworks/base/core/res/res/values/config.xml
```
    <!-- Control the behavior when the user long presses the power button.
         0 - Nothing
         1 - Global actions menu
         2 - Power off (with confirmation)
         3 - Power off (without confirmation)
    -->
    <integer name="config_longPressOnPowerBehavior">1</integer>
    <integer name="config_shortPressOnPowerBehavior">4</integer>
    <integer name="config_globalActionsKeyTimeout">500</integer>
```
frameworks/base/core/res/res/values/config.xml
```
    <!-- Control the behavior when the user short presses the power button.
            0 - Nothing
            1 - Go to sleep (doze)
            2 - Really go to sleep (don't doze)
            3 - Really go to sleep and go home (don't doze)
    -->
    <integer name="config_shortPressOnPowerBehavior">4</integer>
```

# usb 权限
为了避免SLAM Demo运行时提示用户USB permission, 最好把android系统的usb permission 对话框取消，
frameworks/base/core/res/res/values/config.xml    <bool name="config_disableUsbPermissionDialogs">false</bool> 
这个值改成true, 不然的话用户每次插拔usb设备， 再启动slam demo, 都会弹出对话框， VR设备不方便点击 