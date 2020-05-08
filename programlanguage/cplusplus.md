# closure
# Lambda expressions
![](https://docs.microsoft.com/en-us/cpp/cpp/media/lambdaexpsyntax.png)
1. capture clause (Also known as the lambda-introducer in the C++ specification.)
2. parameter list Optional. (Also known as the lambda declarator)
3. mutable specification Optional.
4. exception-specification Optional.
5. trailing-return-type Optional.
6.lambda body)

## []captrue
A lambda can introduce new variables in its body (in C++14), and it can also access, or capture, variables from the surrounding scope. A lambda begins with the capture clause (lambda-introducer in the Standard syntax), which specifies which variables are captured, and whether the capture is by value or by reference. 
Variables that have the ampersand (&) prefix are accessed by reference and variables that do not have it are accessed by value.
捕获外部的变量给lambda表达式
[=] 值传递
[&] 引用传递

[examples](https://docs.microsoft.com/en-us/cpp/cpp/examples-of-lambda-expressions)

# share_ptr
![share ptr](https://i-msdn.sec.s-msft.com/dynimg/IC509609.jpeg)
```
    // Use make_shared function when possible.
    auto sp1 = make_shared<Song>(L"The Beatles", L"Im Happy Just to Dance With You");

    // Ok, but slightly less efficient. 
    // Note: Using new expression as constructor argument
    // creates no named variable for other code to access.
    shared_ptr<Song> sp2(new Song(L"Lady Gaga", L"Just Dance"));

    // When initialization must be separate from declaration, e.g. class members, 
    // initialize with nullptr to make your programming intent explicit.
    shared_ptr<Song> sp5(nullptr);
    //Equivalent to: shared_ptr<Song> sp5;
    //...
    sp5 = make_shared<Song>(L"Elton John", L"I'm Still Standing");
```
[see msdn](https://msdn.microsoft.com/en-us/library/hh279669.aspx)
# cv (const and volatile) type qualifiers
* const - Such object cannot be modified: attempt to do so directly is a compile-time error, and attempt to do so indirectly (e.g., by modifying the const object through a reference or pointer to non-const type) results in undefined behavior.
* volatile - volatile accesses cannot be optimized out or reordered  with another visible side effect that is sequenced-before or sequenced-after the volatile access. 
* mutable - applies to non-static class members of non-reference non-const type and specifies that the member does not affect the externally visible state of the class (as often used for mutexes, memo caches, lazy evaluation, and access instrumentation). mutable members of const class instances are modifiable. (Note: the C++ language grammar treats mutable as a storage-class-specifier, but it does not affect storage class.) 可变的，提供在const中可修改与类状态无关成员的方法

# Virtual Inheritance
```
class DisplaySurface : public virtual RefBase {}
```
保证RefBase在多重继承下只有一份实例
Solving the Diamond Problem

# namespace
```
using namespace std;
using std::x
```
# constructor
## Default constructors
```
ClassName() = delete ;  (3) (since C++11)
ClassName() = default ; (4) (since C++11)
```
[ref](https://msdn.microsoft.com/en-us/library/dn457344.aspx)
## explicit constructors
```
struct Foo {
    int mem;
    explicit Foo(int n) : mem(n) {}
};
Foo f(2); // f is direct-initialized:
// constructor parameter n is copy-initialized from the rvalue 2
// f.mem is direct-initialized from the parameter n
//  Foo f2 = 2; // error: constructor is explicit
```

# destructor
## private&protected destructor
If the base class destructor is private or protected then you cannot call delete through the base-class pointer.
But a protected, non-virtual destructor seems to be a bug waiting to happen. Assuming you do not provide a destroy() function, you have to eventually make the dtor public.
destructor声明为private/protected，阻止使用者从基类指针去析构，这样将对象的创建和使用分开，设计上比较合理。

# rtti
## undefined reference to 'typeinfo for android::MediaSource'
This can also happen when you mix -fno-rtti and -frtti code. Then you need to ensure that any class, which type_info is accessed in the -frtti code, have their key method compiled with -frtti. Such access can happen when you create an object of the class, use dynamic_cast etc.
Possible solutions for code that deal with RTTI and non-RTTI libraries:

a) Recompile everything with either -frtti or -fno-rtti 
b) If a) is not possible for you, try the following: