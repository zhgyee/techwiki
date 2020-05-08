# Introduction #

Add your content here.


# Details #

从inline的作用来看，其放置于函数声明中应当也是毫无作用的：inline只会影响函数在translation unit（可以简单理解为C源码文件）内的编译行为，只要超出了这个范围inline属性就没有任何作用了。所以inline关键字不应该出现在函数声明中，没有任何作用不说，有时还可能造成编译错误（在包含了sys/compiler.h的情况下，声明中出现inline关键字的部分通常无法编译通过）；
inline关键字仅仅是建议编译器做内联展开处理，而不是强制。在gcc编译器中，如果编译优化设置为-O0，即使是inline函数也不会被内联展开，除非设置了强制内联（attribute((always\_inline))）属性。

# static inline #
static inline
GCC的static inline定义很容易理解：你可以把它认为是一个static的函数，加上了inline的属性。这个函数大部分表现和普通的static函数一样，只不过在调用这种函数的时候，gcc会在其调用处将其汇编码展开编译而不为这个函数生成独立的汇编码。

# extern inline #
GCC的static inline和inline都很好理解：看起来都像是对普通函数添加了可内联的属性。但是这个extern inline就千万不能想当然地理解成就是一个extern的函数+inline属性了。实际上gcc的extern inline十分古怪：一个extern inline的函数只会被内联进去，而绝对不会生成独立的汇编码！即使是通过指针应用或者是递归调用也不会让编译器为它生成汇编码，在这种时候对此函数的调用会被处理成一个外部引用。另外，extern inline的函数允许和外部函数重名，即在存在一个外部定义的全局库函数的情况下，再定义一个同名的extern inline函数也是合法的。

# 控制inline #
```
# Add your debugging flag (or not) to CFLAGS
ifeq ($(DEBUG),y)
  DEBFLAGS = -O -g -DSCULL_DEBUG # "-O" is needed to expand inlines
else
  DEBFLAGS = -O2
```