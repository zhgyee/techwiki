#/{system,vendor,odm}/etc/init/
The intention of these directories is as follows

* /system/etc/init/ is for core system items such as SurfaceFlinger, MediaService, and logcatd.
* /vendor/etc/init/ is for SoC vendor items such as actions or daemons needed for core SoC functionality.
* /odm/etc/init/ is for device manufacturer items such as actions or daemons needed for motion sensor or other peripheral
      functionality.

see [Android init language reference](https://android.googlesource.com/platform/system/core/+/master/init/readme.txt),
[Android_Booting](http://elinux.org/Android_Booting)