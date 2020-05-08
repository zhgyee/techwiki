# watch
```
watch -n 0.5 xxx-cmd
```
# record  everything you do in terminal
```
#script
```
# 字符串操作（长度，读取，替换） #
| 表达式 |	含义 |
|-----------|----------|
|${#string}	|$string的长度|	 
|${string:position} |	在$string中, 从位置$position开始提取子串|
|${string:position:length} |	在$string中, 从位置$position开始提取长度为$length的子串|
|${string#substring} |	从变量$string的开头, 删除最短匹配$substring的子串|
|${string##substring} |	从变量$string的开头, 删除最长匹配$substring的子串|
|${string%substring} |	从变量$string的结尾, 删除最短匹配$substring的子串|
|${string%%substring} |	 从变量$string的结尾, 删除最长匹配$substring的子串|
|${string/substring/replacement} |	使用$replacement, 来代替第一个匹配的$substring|
|${string//substring/replacement} |	 使用$replacement, 代替所有匹配的$substring|
|${string/#substring/replacement} |	如果$string的前缀匹配$substring, 那么就用$replacement来代替匹配到的$substring|
|${string/%substring/replacement} |	如果$string的后缀匹配$substring, 那么就用$replacement来代替匹配到的$substring|
 	 
# create wiki page index
```
#!/bin/bash
for i in `ls *.md`; 
do 
	a=${i%.md}; 
	echo "* [$a]($a)" ; 
done
```

# sudo sub command not found
The other solutions I've seen here so far are based on some system definitions, but it's in fact possible to have sudo use the current PATH (with the env command) and/or the rest of the environment (with the -E option) just by invoking it right:
```
sudo -E env "PATH=$PATH" <command> [arguments]
In fact, one can make an alias out of it:

alias mysudo='sudo -E env "PATH=$PATH"'
```

# Find source file
`find . -name \*.h -print -o -name \*.cpp -print`

# 如何区分特殊字符 #
将字符串用''引起来即可

# mount #
```
busybox mount -t nfs -o nolock -o tcp 10.157.186.83:/home/share/ /mnt/smb/
mount -t ufsd -o nls=utf8 -o force /dev/sda2 usb/
```

# 批量修改文件名

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

[xargs](xargs.md)

[autotools](autotools.md)

[repo](repo.md)
