# Introduction #

Add your content here.


# Details #

# 从高到低遍历数组 #

优先使用while --i组合，这样更容易理解；
```
int i = n;
while (--i > 0) {
  a[i];//do something with a[i]
}
```

相应的for的方式
```
for (int i = n; i > 0;) {
  a[--i];//do something with a[i]
}
```