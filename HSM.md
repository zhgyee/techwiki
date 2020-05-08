# Introduction #

Add your content here.


# Details #
# hsm\_init #
  * 如果从指定状态初始化，则要求先找到其父状态，再从其父状态执行ENTRY,一路到当前状态。
```
/*trig STM_ENTRY_SIG from father source state to nested children state*/
do {        
	STM_ENTER(path[ip]);                         
	--ip;
} while (ip >= 0);
```
  * 最后设置稳定状态
# hsm\_exceute #
  * 从当前状态开始处理所给事件，如果当前状态不能处理，则送给父状态去处理
  * 处理状态转换
    * 从一状态到另一状态，要经过两者的父状态
    * 每个状态，都要执行enter/exit
# 转换到父状态 #

通过TRIG进入到临时状态的回调函数QHsmTst\_s1
```
STM_TRIG(me->temp, STM_EMPTY_SIG);
```
在临时状态回调函数中，在default分支中，转换到父状态回调函数QHsmTst\_s
```
default: {
    status = STM_FATHER(&QHsmTst_s);
    break;
}
```