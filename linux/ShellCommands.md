# 远程拷贝 #
```
scp /g/workspace/exynos/7420.tgz  weller@192.168.1.110:/home/weller/

```
# 图片批量裁剪
```
for i in `seq 1 8`
do echo converting $i.png
convert grid$i.png -crop 1280x1440+0+0 new/grid$i.png
done

```
# sudo sub command not found
The other solutions I've seen here so far are based on some system definitions, but it's in fact possible to have sudo use the current PATH (with the env command) and/or the rest of the environment (with the -E option) just by invoking it right:
```
sudo -E env "PATH=$PATH" <command> [arguments]
In fact, one can make an alias out of it:

alias mysudo='sudo -E env "PATH=$PATH"'
```

#Find source file
`find . -name \*.h -print -o -name \*.cpp -print`

# 如何区分特殊字符 #
将字符串用''引起来即可

# mount #
```
busybox mount -t nfs -o nolock -o tcp 10.157.186.83:/home/share/ /mnt/smb/
mount -t ufsd -o nls=utf8 -o force /dev/sda2 usb/
```

#批量修改文件名

```
find / -type f -name '*.LOG'  > old
for i in `cat old`;do mv $i ${i/.LOG/.log}; done
```

# for loop #

```
for line in `cat $1`
do
#  echo ${line:0:1};
  if [ ${line:0:1} != "#" ];
  then
    echo downloading $line;
    wget https://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/$2/$line
  fi
done
~     
```
[ref](http://www.cyberciti.biz/faq/bash-for-loop/)
```
for (( c=1; c<=5; c++ ))
do
   echo "Welcome $c times"
done
```