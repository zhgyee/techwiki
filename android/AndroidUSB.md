# fastboot驱动不能识别问题解决
确保pid/vid能与外界提供的驱动兼容，Windows系统USB驱动检测需要对比驱动.inf文件跟设备pid/vid，[ref](https://docs.microsoft.com/en-us/windows-hardware/drivers/display/driver-matching-criteria)
```
Match type (INF matches are listed under the models section as Description=Install Section, HWID, CompatID. With 0 or 1 HW IDs and 0 or more CompatIDs)

Device HardwareID == INF HardwareID
Device HardwareID == INF CompatID
Device CompatID == INF HardwareID
Device CompatID == INF CompatID
```

1. 下载adb-setup-1.4.3
打开android_winusb.inf文件查看该驱动支持的pid
```
;Project Tango (generic)
%SingleBootLoaderInterface% = USB_Install, USB\VID_18D1&PID_4D00
%CompositeAdbInterface%     = USB_Install, USB\VID_18D1&PID_4D02&MI_01
%CompositeAdbInterface%     = USB_Install, USB\VID_18D1&PID_4D04&MI_02
%CompositeAdbInterface%     = USB_Install, USB\VID_18D1&PID_4D06&MI_01
%CompositeAdbInterface%     = USB_Install, USB\VID_18D1&PID_4D07
```

2. 修改fastboot下的pid为驱动支持的pid
```
diff --git a/bootable/bootloader/drivers/usb/gadget/fastboot-ss.c b/bootable/bootloader/drivers/usb/gadget/fastboot-ss.c
index bc33739..1001bcb 100755
--- a/bootable/bootloader/drivers/usb/gadget/fastboot-ss.c
+++ b/bootable/bootloader/drivers/usb/gadget/fastboot-ss.c
@@ -67,7 +67,7 @@ unsigned int ptable_default_size = sizeof(ptable_default);
 #define FBOOT_USBD_DETECT_IRQ() EXYNOS_USBD_DETECT_IRQ()
 #define FBOOT_USBD_CLEAR_IRQ()  EXYNOS_USBD_CLEAR_IRQ()
 #define VENDOR_ID      0x18D1
-#define PRODUCT_ID     0x0002
+#define PRODUCT_ID     0x4D07
 #define FB_PKT_SZ      64 // full-speed mode
 #define OK     0
 #define ERROR  -1
```
3. 重新刷bootloader并安装adb-setup-1.4.3提供的驱动，fastboot就可以正常使用

# MTP不能识别问题
也是同样修改pid/vid，确保现有的驱动可以识别
```
diff --git a/device/samsung/hmd8895/conf/init.samsung.usb.rc b/device/samsung/hmd8895/conf/init.samsung.usb.rc
index 80a4f53..1495f0a 100755
--- a/device/samsung/hmd8895/conf/init.samsung.usb.rc
+++ b/device/samsung/hmd8895/conf/init.samsung.usb.rc

-    write /sys/kernel/config/usb_gadget/g1/configs/c.1/MaxPower 0x3f
+    write /sys/kernel/config/usb_gadget/g1/configs/c.1/MaxPower 0xfa
+    write /sys/kernel/config/usb_gadget/g1/os_desc/qw_sign "MSFT100"
+    symlink /sys/kernel/config/usb_gadget/g1/configs/c.1 /sys/kernel/config/usb_gadget/g1/os_desc/c.1
 on property:sys.usb.config=mtp,adb
     write /sys/class/android_usb/android0/enable 0
-    write /sys/kernel/config/usb_gadget/g1/idProduct 0x6860
+    write /sys/kernel/config/usb_gadget/g1/idProduct 0x6862
     write /sys/kernel/config/usb_gadget/g1/idVendor 0x04E8
+    write /sys/kernel/config/usb_gadget/g1/os_desc/use 1
+    write /sys/kernel/config/usb_gadget/g1/functions/mtp.0/os_desc/interface.MTP/compatible_id "MTP"

```