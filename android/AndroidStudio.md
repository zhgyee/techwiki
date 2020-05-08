# app key
as默认key所在位置C:\Users\svr00003\.android\debug.keystore
同一个工程不同人编译出来，签名不同，就是因为各自的debug.keystore不同

# gradle相关
gradle本地目录为C:\Users\svr00003\.gradle\wrapper\dists

如果出现gradle无法下载或gradle解析错误，都可以到这个目录下更新相应的gradle版本即可

# 应用网速统计
打开network statis可以查看某个应用的实时网速

so run nano idea.properties
and add this line at the end of the script

disable.android.first.run=true

save the script and the run
> ./studio.sh

> On the window that appears go to configaration>http proxy  then set your proxy.

Exit and then edit idea.properties file and remove the line you added, then run

./studio.sh

You are good to go now.

Happy coding.

# build with ndk
app/build.gradle
```
    tasks.withType(JavaCompile) {
        compileTask -> compileTask.dependsOn 'ndkBuild', 'copyJniLibs'
    }


task ndkBuild(type: Exec) {
    def ndkDir = project.plugins.findPlugin('com.android.application').sdkHandler.getNdkFolder()
    commandLine "$ndkDir/ndk-build", '-C', 'src/main/jni',
            "NDK_OUT=$buildDir/ndk/obj",
            "NDK_APP_DST_DIR=$buildDir/ndk/libs/\$(TARGET_ARCH_ABI)"
}

task copyJniLibs(type: Copy) {
    from fileTree(dir: file(buildDir.absolutePath + '/ndk/libs'), include: '**/*.so')
    into file('src/main/jniLibs')
}
```
# apk打包增加so
在build.gradle中增加下面代码，其中libs为so所在的路径，libs下面为各个abi目录
```
    sourceSets {
        main {
            // let gradle pack the shared library into apk
            jniLibs.srcDirs = ['libs']
        }
    }
```
模块中指定so路径
```
model {
    android {
        sources {
            main {
                jniLibs {
                    'libs'
                }
            }
        }
    }
}
```
# 打包aar
```
allprojects {
    repositories {
        mavenCentral()
        //add it to be able to add depency to aar-files from libs folder in build.gradle(yoursAppModule)
        flatDir {
            dirs 'libs'
        }
    }
}
dependencies {
    //your project depencies
    ...
    //add lib via aar-depency
    compile(name: 'aarLibFileNameHere', ext: 'aar')
    //add all its internal depencies, as arr don't have it
    ...
}
```
或者导入aar，然后增加模块依赖
# debug
## debug symbol directory
在run->edit configrations->app->debugger->symbol directorys下面添加ndkBuild目录，debugger一般会自动查找到所需要的库。