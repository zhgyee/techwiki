

# 自动挂载 #

在/etc/fstab中设置自动挂载

在/etc/mtab中查看已挂载

# mount windows文件系统
```
sudo mount.cifs -o domain=spreadtrum,username=trac,password=xx //10.x.1.110/xx/xx/xx /home/user/xx/
sudo mount -o domain=spreadtrum,username=trac,password=xx //10.x.1.110/xx/xx/xx /home/user/xx/
```
