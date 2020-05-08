# Introduction #

Add your content here.


# Details #
##  列出匹配行前后10号 ## 
-A 和 -B就是指该数值
```
grep -n -A 10 -B 10 "40060c" dump.s
```

##  只列出文件名 ## 

```

grep -l pattern files ：只列出匹配的文件名， 
grep -L pattern files ：列出不匹配的文件名

```