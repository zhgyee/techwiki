# pc configure
```
sudo apt-get install libsdl2-dev
 ./configure 
 make -j

```
# live streaming using ffmpeg
## run ffserver
`./ffserver -f tests/ffserver.conf &`
## using ffmpeg feed the server
`./ffmpeg -i ~/Videos/SEX-360.mp4 http://localhost:9999/feed1.ffm`
## using ffplay to veriry the server
`./ffplay http://localhost:9999/test -loglevel debug`

# Arch byte ops#
 Arch-specific headers can provide any combination of
 AV_[RW][BLN](16|24|32|48|64) and AV_(COPY|SWAP|ZERO)(64|128) macros.
 Preprocessor symbols must be defined, even if these are implemented
 as inline functions.

 R/W means read/write, B/L/N means big/little/native endianness.
 The following macros require aligned access, compared to their
 unaligned variants: AV_(COPY|SWAP|ZERO)(64|128), AV_[RW]N[8-64]A.
 Incorrect usage may range from abysmal performance to crash
 depending on the platform.

 The unaligned variants are AV_[RW][BLN][8-64] and AV_COPY*U.
 
# FFMPEG usefull command-line
## play rtsp
`/ffplay rtsp://192.168.249.14:8554/girl-360.264 -rtsp_transport tcp -loglevel debug`
## yuv format convert
`ffmpeg.exe -s 720x480 -i input.yuv -pix_fmt nv12 output.yuv`
## es to mp4
`ffmpeg -i video_es.h264 -vcodec copy video_es.mp4`
## scale video
`ffmpeg -i a.mov -vf scale=853:480 -acodec aac -vcodec h264 out.mp4`

# Android build #
build in SDK
```
SYSROOT=$ANDROID_BUILD_TOP/prebuilts/ndk/9/platforms/android-9/arch-arm
ANDROID_ARM_TOOL_CHAIN_PREFIX=$ANDROID_TOOLCHAIN/arm-linux-androideabi-
function build_one
{
./configure \
--prefix=$PREFIX \
--disable-shared \
--enable-static \
--disable-doc \
--disable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--disable-ffserver \
--disable-avdevice \
--disable-doc \
--disable-symver \
--cross-prefix=$ANDROID_ARM_TOOL_CHAIN_PREFIX \
--target-os=linux \
--arch=arm \
--enable-cross-compile \
--sysroot=$SYSROOT \
--extra-cflags="-Os -fpic $ADDI_CFLAGS" \
--extra-ldflags="$ADDI_LDFLAGS" \
$ADDITIONAL_CONFIGURE_FLAG
make clean
make -j32
make install
}
CPU=arm
PREFIX=$(pwd)/android/$CPU
ADDI_CFLAGS="-marm"
build_one
```
build in NDK
```
#!/bin/bash
NDK=/home/zhangyi/workspace/NDK/android-ndk-r9b
SYSROOT=$NDK/platforms/android-9/arch-arm/
TOOLCHAIN=$NDK/toolchains/arm-linux-androideabi-4.6/prebuilt/linux-x86_64
function build_one
{
./configure \
--prefix=$PREFIX \
--disable-shared \
--enable-static \
--disable-doc \
--disable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--disable-ffserver \
--disable-avdevice \
--disable-doc \
--disable-symver \
--cross-prefix=$TOOLCHAIN/bin/arm-linux-androideabi- \
--target-os=linux \
--arch=arm \
--enable-cross-compile \
--sysroot=$SYSROOT \
--extra-cflags="-Os -fpic $ADDI_CFLAGS" \
--extra-ldflags="$ADDI_LDFLAGS" \
$ADDITIONAL_CONFIGURE_FLAG
make clean
make
make install
}
CPU=arm
PREFIX=$(pwd)/android/$CPU
ADDI_CFLAGS="-marm"
build_one
```
