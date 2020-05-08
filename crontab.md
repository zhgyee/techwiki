# Introduction #

Add your content here.


# 定时锁屏 #

```
0-3/1 * * * * DISPLAY=:0 notify-send -i /home/thundersoft/pics/rest.png "提醒" "您需要休息了." >> /home/thundersoft/notify-send.log 2>&1
4 * * * * DISPLAY=:0 notify-send -i /home/thundersoft/pics/rest.png "提醒" "桌面约在1分钟后锁定." >> /home/thundersoft/cnotify-send.log 2>&1
5 * * * * DISPLAY=:0 gnome-screensaver-command -l >> /home/thundersoft/notify-send.log 2>&1

```

##  Reference ## 

http://linuxtools-rst.readthedocs.org/zh_CN/latest/tool/crontab.html

http://xwsoul.com/posts/519