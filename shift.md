# Introduction #

Add your content here.


# Details #

Computing remainders modulo a power of 2 with unsigned types is equivalent to a bit-and:
```
ulong a = b % 32; // == b & (32-1)
```

Division
with signed types rounds toward zero, as one would expect, but right shift is a division (by a power of 2)
that rounds to 负无穷:
```
int a = -1;
int c = a >> 1; // c == -1
int d = a / 2; // d == 0
```
所以在负数的移位运算中，要做修补
```
12:test.cc @ int d = a / 2;
293 000b 89C2 movl %eax,%edx
294 000d C1EA1F shrl $31,%edx // fix: %edx=(%edx<0?1:0)
295 0010 01D0 addl %edx,%eax // fix: add one if a<0
296 0012 D1F8 sarl $1,%eax
```