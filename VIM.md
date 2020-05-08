# Introduction #

Add your content here.

[taglist](taglist.md)

# vimdiff
```
vimdiff [file1] [file2]
set scrollbind
:set diff//Redoing the diff
ctrl-w w//Switch viewport
]c//jump to next
[c//junp to prev
:diffget//To replace a diff in the current viewport with that from the other viewport
:do//diffget
:diffput //To replace a diff in the other viewport with that from the current viewport
:dp//diffput
:63diffget//just get line 63
:63,67diffget//get line 63~67
```

# commands #

命令格式快速参考
[cheatsheet](http://www.fprintf.net/vimCheatSheet.html)

# 十六进制编辑 #

1.  这两个命令都可以以十六进制打印输出 二进制文件内容。可以指定偏移和打印格式等
hexdump  xxd

2。   Vim 可以用来查看和编辑二进制文件
vim -b egenea-base.ko   加上-b参数，以二进制打开
然后输入命令  :%!xxd -g 1  切换到十六进制模式显示

然后就可以像修改文本文件一样修改16进制的字符，可以 用 / 查找指定的偏移等等。修改右边的ascii字符应该无效。
修改完成后再执行   ;%!xxd -r  切换会二进制模式，然后再 :wq 保存退出就可以了。在这vim里面这样编辑还是很方便的，注意一定要;%!xxd -r切换回来之后在保存才行。

4.  比较两个二进制文件，可以使用vimdiff。
vimdiff应该还是比较好用的，类似windows 平台的windiff
vim -bd base.ko base2.ko
打开后就可以在两个窗口里面显示两个文件
ctrl + W +L  把输入焦点切换到右边的窗口，激活右边的窗口后输入的命令就是针对右窗口了
:%!xxd -g 1  切换成十六进制的一个字节的模式
ctrl + W +H  把输入焦点切换到左边的窗口
:%!xxd -g 1
] + c  查找上一个不同点
[ + c  查找下一个不同点
> 0012930: 89 df 68 77 01 00 00 e8 fc ff|  0012930: 89 df 68 78 01 00 00 e8 fc f