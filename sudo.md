# Introduction #

Add your content here.


# Details #

# 开放部分应用权限 #

在/etc/sudoers中增加如下：
```
andrew ALL=(ALL)    NOPASSWD: /bin/mount, /bin/umount
```