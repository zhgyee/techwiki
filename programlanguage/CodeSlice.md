# Introduction #


# 自动锁的实现 #
```
#define AUTO_LOCK(lock, ops) {\
    int __lock_ret = pthread_mutex_lock(&lock);\
    if (!__lock_ret) {\
        ops;\
        pthread_mutex_unlock(&lock);\
    }}
```
使用示例：
```
    AUTO_LOCK(cm->lock, {
        /*Wait until critical state exit*/
        while (!cm->bReady)
        {
            ret = pthread_cond_wait(&cm->cond, &cm->lock);
            CHECK(ret, break, "pthread_cond_wait failed");
        }
        ret = _CACHE_MANAGER_ReadAt_L(cm, pos, data, size);
    });
```

# 打印出代码码的执行时间 #

```
#define DEBUG_BLOCK_BEG() {\
    HI_U32 __start =  GetSystemTime();\
    HI_U32 __beline = __LINE__;

#define DEBUG_BLOCK_END() printf("[%s,%d~%d] time used:%d\n", __FILE__, __beline, __LINE__, GetSystemTime() - __start);}

```

# goto的替代方案 #

```
/**
 * critical define
 */
#define CRITICAL_STATUS_OK (0)
#define CRITICAL_STATUS_ERR (-1)
#define CRITICAL_ENTER() \
    int __critical_status = CRITICAL_STATUS_OK;\
    do {
#define CRITICAL_LEAVE() } while (0);
#define LEAVE_CRITICAL __critical_status = CRITICAL_STATUS_ERR;break
#define TEST_CRITICAL_STATUS() __critical_status == CRITICAL_STATUS_OK
```