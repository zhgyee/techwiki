#Linker Version Scripts
The version script can be specified to the linker by means of the `--version-script' linker command line option. 
```
VERS_1.1 {
     global:
         foo1;
     local:
         old*; 
         original*; 
         new*; 
};

VERS_1.2 {
         foo2;
} VERS_1.1;

VERS_2.0 {
         bar1; bar2;
} VERS_1.2;
```
[ref](http://man7.org/conf/lca2006/shared_libraries/slide18c.html)
#ldd equivalent on android
```
arm-linux-androideabi-readelf -d android-projects/output/gpl/imsdroid/libs/armeabi-v7a/libtinyWRAP.so
```
`$ /lib/ld-linux.so.2 --list filename`
ldd is just a shell script that works like a wrapper around the dynamic loader. The name of the dynamic loader, i.e., ld-{version}.so might differ.
