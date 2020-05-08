# Introduction #

Add your content here.


# Details #

# Display #

```
xrandr
cvt 1920 1080
sudo xrandr --addmode VGA1 "1920x1080_60.00"
sudo xrandr --output VGA1 --mode "1920x1080_60.00"
```
here is the modern way to install the nvidia drivers for Ubuntu (for 14.04 and newer):
add the graphics-drivers ppa. 
```$ sudo add-apt-repository ppa:graphics-drivers/ppa. 
$ sudo apt-get update.
```
install the reccomended driver. 
`$ sudo ubuntu-drivers autoinstall.`
restart your system. 
`$ sudo reboot.`

http://www.cnblogs.com/rossoneri/p/4068274.html

[update-alternatives](update-alternatives.md)
