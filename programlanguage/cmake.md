# Building with CMake
```
cumin[~]$ cd cmake/
cumin[cmake]$ ls
CMakeLists.txt  w01-cpp/
cumin[cmake]$ mkdir build
cumin[cmake]$ ls
CMakeLists.txt  build/  w01-cpp/
cumin[cmake]$ cd build/
cumin[build]$ cmake ..
```
# CMakeLists.txt
## 支持c++11
```
set (CMAKE_CXX_STANDARD 11) 或
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall")
```

## 定义libnative-lib.so
```
# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.4.1)

# Creates and names a library, sets it as either STATIC
# or SHARED, and provides the relative paths to its source code.
# You can define multiple libraries, and CMake builds them for you.
# Gradle automatically packages shared libraries with your APK.
add_library( # Sets the name of the library.
             native-lib

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             src/main/cpp/native-lib.cpp)
```
## 链接其它库
```
# Searches for a specified prebuilt library and stores the path as a
# variable. Because CMake includes system libraries in the search path by
# default, you only need to specify the name of the public NDK library
# you want to add. CMake verifies that the library exists before
# completing its build.

find_library( # Sets the name of the path variable.
              log-lib

              # Specifies the name of the NDK library that
              # you want CMake to locate.
              log )

# Specifies libraries CMake should link to your target library. You
# can link multiple libraries, such as libraries you define in this
# build script, prebuilt third-party libraries, or system libraries.

target_link_libraries( # Specifies the target library.
                       native-lib

                       # Links the target library to the log library
                       # included in the NDK.
                       ${log-lib} )
```
链接android系统库
```
# add lib dependencies
target_link_libraries(gl2jni
                      android
                      log 
                      EGL
                      GLESv2)
```
链接本地库
```
add_library(lib_gmath STATIC IMPORTED)
set_target_properties(lib_gmath PROPERTIES IMPORTED_LOCATION
    ${distribution_DIR}/gmath/lib/${ANDROID_ABI}/libgmath.a)

# shared lib will also be tucked into APK and sent to target
# refer to app/build.gradle, jniLibs section for that purpose.
# ${ANDROID_ABI} is handy for our purpose here. Probably this ${ANDROID_ABI} is
# the most valuable thing of this sample, the rest are pretty much normal cmake
add_library(lib_gperf SHARED IMPORTED)
set_target_properties(lib_gperf PROPERTIES IMPORTED_LOCATION
    ${distribution_DIR}/gperf/lib/${ANDROID_ABI}/libgperf.so)
```
## 指定头文件路径
```
# Specifies a path to native header files.
include_directories(src/main/cpp/include/)
```
## 拷贝文件
* file(COPY ... copies the file in configuration step and only in this step. When you rebuild your project without having changed your cmake configuration, this command won't be executed.
* add_custom_command is the preferred choice when you want to copy the file around on each build step.

只在cmake更改后拷贝
```
file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/interceptor-lib/lib/${ANDROID_ABI}/libinterceptor.so
     DESTINATION ${distribution_DIR}/app/libs/${ANDROID_ABI})
```
每次编译后拷贝
```
add_custom_command(
        TARGET xrapii POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
                ${CMAKE_CURRENT_SOURCE_DIR}/interceptor-lib/lib/${ANDROID_ABI}/libinterceptor.so
                ${distribution_DIR}/app/libs/${ANDROID_ABI})
```
## 输出调试信息
```
message([<mode>] "message to display" ...)
FATAL_ERROR    = CMake Error, stop processing and generation
WARNING        = CMake Warning, continue processing
```
# Ref
https://www.cs.swarthmore.edu/~adanner/tips/cmake.php