# delegate
delegate类似于C++中的函数对象，可以指向静态函数或成员函数， delegate是对象，在使用过程中要考虑对象的生命周期。
A delegate is a type that safely encapsulates a method, similar to a function
pointer in C and C++. Unlike C function pointers, delegates are object-oriented,
type safe, and secure. The type of a delegate is defined by the name of the delegate.