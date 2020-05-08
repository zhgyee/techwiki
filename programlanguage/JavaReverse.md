# 使用到的工具:

* apktool: 反编译工具，通过反编译APK中XML文件，直接可以查看。https://bitbucket.org/iBotPeaches/apktool/downloads
* dex2jar: 将apk中的classes.dex转化成Jar文件。http://code.google.com/p/innlab/downloads/lis
* JD-GUI：反编译工具，可以直接查看Jar包的源代码。http://code.google.com/p/innlab/downloads/lis
* APK反编译工具包： 集合了apktool，直接右键即可对apk,dex进行反编译 http://code.google.com/p/innlab/downloads/lis
* ClassyShark: 一款可以查看Android可执行文件的浏览工具，支持.dex, .aar, .so, .apk, .jar, .class, .xml 等文件格式，分析里面的内容包括classes.dex文件，包、方法数量、类、字符串、使用的NativeLibrary等.
https://github.com/google/android-classyshark （下载release包）
* AndroidStudio可以直接浏览apk，查看Manifest文件
* smali2java 可以直接反编译apk为java源码, smali2java只能单个转换文件，最好先搜索smali文件，找到要reverse的文件

# apktool
用apktool解压apk，修改源文件，然后使用apktool再编译为apk
```
$ apktool d test.apk
$ apktool b test
```
# 反编译流程
## 解压APK包
apk文件是一种常见的zip, 后缀重命名后即可解压。得到xml和classes.dex文件，这时候就可以获取到一些图片资源文件和assets资源了。
## 反编译dex文件
要查看java源码，就要对这个classes.dex进行反编译了。
首先，先用dex2jar把dex转为普通的jar包。
```
dex2jar.bat classes.dex
```
此时会生成classes_dex2jar.jar包。

## 或才直接使用dex2jar将apk转为jar
```
d2j-dex2jar.bat -f .\xxx.apk
```

## 反编译jar包
这时候就可以使用JD_GUI进行查看jar包里面的代码了，JD_GUI也可以对单个class文件反编译。

使用JD_GUI导出源码后，可以在andorid studio里设置class源码路径，这样可以直接在AS里查看。
## 反编译XML文件
当然你解压apk后，得到很多的xml文件，但是你查看你会发现是乱码，这时候你需要使用apktool。
方法一：
直接使用apktool进行反编译
```
apktool d xxx.apk
```
会生成xxx目录，里面res的xml文件可以正常查看。

## ClassyShark反编译
打开界面
```
java -jar ClassyShark.jar
```
点击左上角按钮，打开文件。
Methods count里面即可看到引用了哪些包，方法数。
通过包来判断使用了哪些开源包。

[参考来源](http://www.jianshu.com/p/792c86023a02)