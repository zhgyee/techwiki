# build data


```
//__DATE__ gives something like "Jul 27 2012"
//__TIME__ gives something like 21:06:19
#define BUILD_YEAR ((__DATE__[7] - '0') * 1000 +  (__DATE__[8] - '0') * 100 + (__DATE__[9] - '0') * 10 + __DATE__[10] - '0')
#define BUILD_DATE ((__DATE__[4] - '0') * 10 + __DATE__[5] - '0')

#define BUILD_MAJOR 1
#define BUILD_MINOR 4
#define VERSION STRINGIZE(BUILD_MAJOR) "." STRINGIZE(BUILD_MINOR)
char build_str[] = {
    BUILD_MAJOR + '0', '.' BUILD_MINOR + '0', '.',
    __DATE__[7], __DATE__[8], __DATE__[9], __DATE__[10],
    '\0'
};
```