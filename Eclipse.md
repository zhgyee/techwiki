# Introduction #

Add your content here.

# android sdk project setup
```
cp development/ide/eclipse/.classpath .

● Start Eclipse
● Create new "Java project"
● Project name = your AOSP name
● Deselect "Use default location"
● Location = path to your AOSP
● Click "Next"
● Wait a little bit ...
● Click "Finish"
● Wait for it to build your project
● ... it likely will fail ...

keep out dir in project for R.*
```
# link with editor #
* 在outline中设置该项后，在编辑器中定位到哪个函数，就会在outline中显示函数名
* 在左侧文件浏览里link的话，会跟随打开文件

# using autotools #

# 使用eclipse静态分析代码
* 在最底层函数上使用opencall hierarchy，可以看到调用堆栈
* 在类名上使用open type hierarchy可以看到该类被使用的情况

#Android JNI index
add JNI include path under "preprocessor include path" tag

#Android app setting
 * properties->Android->isLibrary==>build project as a xx.jar lib
 * properties->Java build path->libraries->add external JARs===>add external JAR for dependence
 * properties->Java build path->order & Export===>choose JAR refer priority
 * if a reference project contains index error, current project will lunch fail, and should remove project reference

#Your Project contains error(s), please fix them before running your application
project build ok, build contains index error, solutions:
Windows->Show Views->Problems shows  errors
delete these item, and then rebuild ok

#Eclipse compiles successfully but still gives semantic errors
