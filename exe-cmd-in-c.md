#system

#popen
```
int main(int argc,char *argv[]){    
    FILE* file = popen("ntpdate", "r");
    char buffer[100];
    fscanf(file, "%100s", buffer);
    pclose(file);
    printf("buffer is :%s\n", buffer);
    return 0;
}
```
##get thead id by popen
```
snprintf(buf, sizeof(buffer), "cat /proc/%d/task/*/stat | grep %s", getpid(), thread_name);
FILE* file = popen(buffer, "r");
fgets(buffer, sizeof(buffer), file);
sscanf(buffer, "%d", &pid);
pclose(file)
```