# Exploring the Gradle Files
* Top-Level Gradle Build File
Every Android Studio project contains a single, top-level Gradle build file. This build.gradle file is the first item that appears in the Gradle Scripts folder and is clearly marked Project.
* Module-Level Gradle Build Files
In addition to the project-level Gradle build file, each module has a Gradle build file of its own
* gradle-wrapper.properties (Gradle Version)
This file allows other people to build your code, even if they don't have Gradle installed on their machine. This file checks whether the correct version of Gradle is installed and downloads the necessary version if necessary. 
* settings.gradle
This file references all the modules that make up your project.
* gradle.properties (Project Properties)
This file contains configuration information for your entire project. It's empty by default, but you can apply a wide range of properties to your project by adding them to this file.
* local.properties (SDK Location)
This file tells the Android Gradle plugin where it can find your Android SDK installation.

# Build From Command Line
```
gradlew task-name
//To see a list of all available build tasks for your project, execute tasks:
gradlew tasks
//To build a debug APK
gradlew assembleDebug
gradlew installDebug
//在bat脚本中构建工程
call samples\apps\atw\projects\android\gradle\atw_opengl\gradlew -b samples\apps\atw\projects\android\gradle\atw_opengl\build.gradle --project-cache-dir build\android\gradle\apps\atw_opengl\.gradle build
```

# build.gradle示例
```
	android.sources {
		main {
			manifest.source {
				srcDir './'
				include 'AndroidManifest.xml'
			}
			jni.source {
				srcDir "${baseDir}/samples/apps/atw"
				include "atw_opengl.c"
				exclude "atw_vulkan.c"
				exclude "atw_cpu_dsp.c"
			}
		}
	}
```