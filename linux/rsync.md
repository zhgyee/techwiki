# Introduction #

rsync表示 remote sync，其用于在本地或与远程主机间进行文件或目录备份。


# Details #
示例：
```
rsync -vaLW --timeout=60 --contimeout=60 rsync://fate.ffmpeg.org/fate-suite/ $(SAMPLES)
```

Rsync provides a method for doing this by passing the -n or --dry-run options. The -v flag (for verbose) is also necessary to get the appropriate output:
```
rsync -anv dir1/ dir2
```

# 参考 #

http://www.cnblogs.com/bangerlee/articles/3003243.html
https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories-on-a-vps