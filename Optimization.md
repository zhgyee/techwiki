# Introduction #

Add your content here.


# Details #

The old trick to swap variables without using a temporary is pretty much out of fashion today:
```
// a=0, b=0 a=0, b=1 a=1, b=0 a=1, b=1
a ^= b; // 0 0 1 1 1 0 0 1
b ^= a; // 0 0 1 0 1 1 0 1
a ^= b; // 0 0 1 0 0 1 1 1
// equivalent to: tmp = a; a = b; b = tmp;
```
However, under some conditions (like extreme register pressure) it may be the way to go. **Note that if both operands are identical (memory locations) then the result is zero.**