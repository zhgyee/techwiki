# Introduction #

Add your content here.


# Details #

示例：
```
extern double sqrt(double x) __attribute__((weak));

int main()
{
    if (sqrt)
    {
        printf("sqrt %f\n", sqrt(4));
    }
    else
    {
        printf("not exists sqrt,use userdef sqrt\n");
    }
    return 0;
}

$ gcc test.c
$ ./a.out
not exists sqrt,use userdef sqrt
$ gcc test.c -lm
$ ./a.out
sqrt 2.000000
```

通过声明弱符号，来解决在不同平台上函数不同的问题

原理：弱符号在链接符号定义时但又找不到的情况下，会给符号置0