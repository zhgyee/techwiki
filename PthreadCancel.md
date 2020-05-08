# Introduction #

Add your content here.


# Details #

```
if ( (status = pthread_kill(pthread_id, SIGUSR1)) != 0) 
{ 
printf("Error cancelling thread %d, error = %d (%s)", pthread_id, status, strerror status));
} 

USR1 handler:

struct sigaction actions;
memset(&actions, 0, sizeof(actions)); 
sigemptyset(&actions.sa_mask);
actions.sa_flags = 0; 
actions.sa_handler = thread_exit_handler;
rc = sigaction(SIGUSR1,&actions,NULL);
void thread_exit_handler(int sig)
{ 
printf("this signal is %d \n", sig);
pthread_exit(0);
}
```