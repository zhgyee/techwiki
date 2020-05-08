# 内核中写property
```
    if (!strncmp(name, "samsung_lcd", 11)) {	
	char buff[PROP_NAME_MAX];
	 int len = snprintf( buff, sizeof(buff), "ro.kernel.samsung_lcd" );
	 if (len < (int)sizeof(buff))
		   property_set( buff, value );
		   return;
    }
```

# 让应用程序具有写property的权限 #

media server没有写property的权限，通过在system/core/init/property\_service.c中增加：
```
{ "media.",           AID_MEDIA,    0 },
```

可以让media server 写 media.xxx前缀的property，
修改完后需要重新编译更新内核。

#虚拟按键显示方法：
adb pull /system/build.prop ./
将build.prop最后一行添加：emu.hw.mainkeys=0
push build.prop后重启