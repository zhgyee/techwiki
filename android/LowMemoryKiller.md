# Low memory killer根据两个原则，进程的重要性和释放这个进程可获取的空闲内存数量，来决定释放的进程。
（1）进程的重要性，由task_struct->signal_struct->oom_adj决定。

Android将程序分成以下几类，按照重要性依次降低的顺序：
名称 oom_adj 解释 
```
FOREGROUD_APP 0 前台程序，可以理解为你正在使用的程序 
VISIBLE_APP 1 用户可见的程序 
SECONDARY_SERVER 2 后台服务，比如说QQ会在后台运行服务 
HOME_APP 4 HOME，就是主界面 
HIDDEN_APP 7 被隐藏的程序 
CONTENT_PROVIDER 14 内容提供者， 
EMPTY_APP 15  空程序，既不提供服务，也不提供内容
```
[ref](http://blog.csdn.net/mznewfacer/article/details/7313597)