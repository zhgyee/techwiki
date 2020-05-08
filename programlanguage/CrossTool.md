# Introduction #

Add your content here.


# Install needed packages #
```
sudo apt-get install autoconf automake libtool libexpat1-dev \
libncurses5-dev bison flex patch curl cvs texinfo \
build-essential subversion gawk python-dev gperf
```

##  Build Crosstool-NG ## 
```
./bootstrap
./configure --enable-local
make
make install
```
##  Configure the toolchain to produce ## 
```
ct-ng list-samples
ct-ng arm-unknown-linux-uclibcgnueabi
ct-ng menuconfig
```
For S3c2440 set follows:
```
 Target options  --->
           *** Target optimisations ***
           (armv4t) Architecture level 
           (arm9tdmi) Emit assembly for CPU    
           (arm920t) Tune for CPU
```
```
ct-ng build
```

##  Reference ## 

http://free-electrons.com
"Embedded Linux Training Lab book"

[用crosstool-ng建立Linux交叉编译环境（以S3C2440（armv4t）为例）](http://blog.chinaunix.net/uid-24404030-id-2609440.html)