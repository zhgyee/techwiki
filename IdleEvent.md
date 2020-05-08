# Introduction #

通过事件机制提供共用stack的一种方案。
protothread也是一种方案，但是否比较难用呢？目前没有亲自尝试
共用stack的这种方法，根本上是就是在一个线程上执行多个过程，每个过程的上下环境都要自己保存起来。
IdleEvent是如何保存的呢？是通过STM来完成的吗？
# DataStruct #
```
ACTIVE_EVENT_STRUCT_CB
  |--------------------ACTIVE_EVENT_STRUCT
  |--------------------IDLE_QUEUE_MSG
```
```
typedef struct ACTIVE_EVENT_STRUCT_CB {
    ACTIVE_EVENT_STRUCT *act;        
    IDLE_QUEUE_MSG    *queue;          
    RAW_U8 end;                 
	
} ACTIVE_EVENT_STRUCT_CB;

typedef struct ACTIVE_EVENT_STRUCT {

	STM_STRUCT super;            
	RAW_U8 prio;
        RAW_U8 head;
	RAW_U8 tail;
	RAW_U8 nUsed;

} ACTIVE_EVENT_STRUCT;

```
# Methods #

> ##  idle\_event\_init ## 
  * idle\_ready\_flag = 0
> > idle\_ready\_flag是一个bitset，查找第一个bit 1就可以找出ready queue
  * 初始化ACTIVE\_EVENT\_STRUCT的内部队列。

> ##  idle\_event\_post ## 
> ##  idle\_run ## 