# 无法创建链接问题
如果host文件系统不支持链接，如windows，则guest上不能创建共享文件夹内的链接
```
ln -fs out/Release/node node
ln: failed to create symbolic link `node': Read-only file system
```
Fix: Enable symlinks feature in VirtualBox    
Run at cmd prompt:
```
VBoxManage setextradata YOURVMNAME VBoxInternal2/SharedFoldersEnableSymlinksCreate/YOURSHAREFOLDERNAME 1
```
Verify by running:
```
VBoxManage getextradata YOURVMNAME enumerate
```
If your user belongs to Administrators group then start VirtualBox with "Run as Administrator"!

# virtualbox中无法启用usb设备 
```
1、使用环境
os： ubuntu 12.04 alternate
vb： virtualbox 4.1.12
Oracle VM Pack
2、问题说明
在虚拟机setting中的usb设置中虽然可以增加usb filter contrallor，但是无法选择具体宿主机上的usb设备，因而无法在虚拟机中使用usb设备
3、问题分析
主要是使用usb设备的权限需要用到管理员，而登录用户一般没哟管理员权限，具体测试可以是哦用如下：
sudo VBoxManage list usbhost
列出宿主机上的所有usb设备
4、解决方法
4.1、简单方法使用管理员启动virtualbox即可了，比如sudo virtualbox& 即可，缺点是需要命令行启动，后台运行，不是很直观、舒服
4.2、一劳永逸型
4.2.1、增加用户组（usbfs)
sudo groupadd usbfs 
4.2.2、将当前用户加入此租
sudo adduser $USER usbfs 
4.2.3、确认group的id
gedit /etc/group，查看其中usbfs的id，记录（比如1001）
4.2.4、修改fstab文件
sudo gedit /etc/fstab，增加如下一行；
none /proc/bus/usb usbfs devgid=1001,devmode=664 0 0
注意devgid=1001中的1001要改成你刚在group中查到的usbfs组的ID。保存文件。
4.2.5、重新启动ubuntu即可
```
# 共享文件夹访问
需要将当前用户增加到vboxfs群组才能打开共享文件夹

# 增加虚拟硬盘 Enlarge virtual drive
```
Enlarge virtual drive

From VirtualBox
	Release the VDI file: File -> Virtual Media Manager -> Select VDI -> Release
	Copy the location of the VDI inside the properties box 'C:\Users\campbell\VirtualBox VMs\Ubuntu14\Ubuntu14.vdi'
	Backup the VDI file
	Copy the VDI file
	Give it a new uuid '.\VBoxManage internalcommands sethduuid 'C:\Users\campbell\VirtualBox VMs\Ubuntu14\Ubuntu14.vdi'
From host
	Work out desired size: you can google it, eg. '40 Gb=MB' returns 40000 MB
	Start PowerShell (not as administrator)
	Change to your Oracle VirtualBox directory cd C:\Program Files\Oracle\VirtualBox
	Resize your .vdi file .\VBoxManage modifyhd 'C:\Users\campbell\VirtualBox VMs\Ubuntu14\Ubuntu14.vdi' --resize 40000
	Now start your virtual machine. You will receive the same warning about space that prompted you to engage in this procedure. Not to worry, we are near the end.
On your virtual machine
	Start the partition manager gparted (install it if is is missing sudo apt-get install gparted)
	Get rid of the swap partition, which prevents you from expanding the root partition. Note that you cannot harm the rest of your machine - this is all happening inside a single file. Worst case scenario you trash this file and you have to use your backup instead.
	Make a note of the size of the linux-swap partition 4 GiB in my case
	Right click on it and Swapoff
	Right click on it and Delete
	Apply by clicking on the checkmark (Apply all operations). Ignore the dire warning - life is too short to indulge Cassandras
	right click on the extended file system that once housed the swap partition (/dev/sda2 in all likelihood) and delete it
	right click on the root partition (/dev/sda1) and resize it. Tab to the 'Free space following' field and enter the size of the swap partition. Shift-Tab and the machine will work out the new size for you automatically.
	Right click in the unallocated space at the end and make it an extended partition
	Right click in the new partition and select linux-swap in the File system field.
	Commit your changes as before
	Right click on your swap partition and select swapon
	Tell the Fat Lady to commence singing.
```