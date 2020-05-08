# Introduction #

Add your content here.


# two's complement #
In two's complement zero is not the only number that is equal to its negative. The value with just the highest bit set (the most negative value) also has this property.
```
c=................ -c=................ c= 0 -c= 0
c=1............... -c=1............... c=-32768 -c=-32768
```
This is why innocent looking code like the following can simply fail:
```
if ( x<0 ) x = -x;
// assume x positive here (WRONG!)
```
# shifts in the C-language #
```
1 static inline ulong first_comb(ulong k)
2 // Return the first combination of (i.e. smallest word with) k bits,
3 // i.e. 00..001111..1 (k low bits set)
4 {
5 ulong t = ~0UL >> ( BITS_PER_LONG - k );
  if ( k==0 ) t = 0; // shift with BITS_PER_LONG is undefined
6 return t;
7 }
```