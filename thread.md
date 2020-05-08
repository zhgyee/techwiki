# Introduction #

Add your content here.


# Details #

C/C++：
```
	#include <sys/prctl.h>
	prctl(PR_SET_NAME, "rtp thread");
```
JAVA：
```
	Thread t = new Thread("rtp thread"); //还有其他参数的构造，都可以加名字的
	Timer t = new Timer("rtp thread"); //还有其他参数的构造，都可以加名字的
```