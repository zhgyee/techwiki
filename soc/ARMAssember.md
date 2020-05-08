# Introduction #

Add your content here.


# Insructions #
[bic](bic.md)

the BIC instruction performs an Rd AND NOT Rm operation.

[mrs](mrs.md)

move to register from status

# 伪指令
## 符号定义（Symbol Definition）伪指令
GBLA、GBLL和 GBLS
```
GBLA  Test1  ；定义一个全局的数字变量，变量名为Test1
Test1  SETA  0xaa  ；将该变量赋值为 0xaa
GBLL  Test2  ；定义一个全局的逻辑变量，变量名为Test2
Test2  SETL  {TRUE} ；将该变量赋值为真
GBLS  Test3  ；定义一个全局的字符串变量，变量名为Test3
Test3  SETS  “Testing” ；将该变量赋值为“Testing”
 ```
LCLA、LCLL和 LCLS
```
LCLA  Test4  ；声明一个局部的数字变量，变量名为Test4
Test3  SETA  0xaa  ；将该变量赋值为 0xaa
LCLL  Test5  ；声明一个局部的逻辑变量，变量名为Test5
Test4  SETL  {TRUE} ；将该变量赋值为真
LCLS  Test6  ；定义一个局部的字符串变量，变量名为Test6
Test6  SETS  “Testing” ；将该变量赋值为“Testing”
```
SETA、SETL和 SETS
```
LCLA  Test3  ；声明一个局部的数字变量，变量名为Test3
Test3  SETA  0xaa  ；将该变量赋值为 0xaa
LCLL  Test4  ；声明一个局部的逻辑变量，变量名为Test4
Test4  SETL  {TRUE} ；将该变量赋值为真
```
RLIST
```
RegList RLIST  {R0-R5，R8，R10} ；将寄存器列表名称定义为RegList，可在ARM指令LDM/STM中通过该名称访问寄存器列表。
``` 
## 数据定义（Data Definition）伪指令
```
DCB:
用于分配一片连续的字节存储单元并用伪指令中指定的表达式初始化
Str DCB “This is a test！”；分配一片连续的字节存储单元并初始化。
 
DCW(DCWU)
用于分配一片连续的半字存储单元并用伪指令中指定的表达式初始化
DataTest  DCW 1，2，3 ；分配一片连续的半字存储单元并初始化。
 
DCD(DCDU)
分配一片连续的字存储单元并用伪指令中指定的表达式初始化
DataTest  DCD 4，5，6 ；分配一片连续的字存储单元并初始化。
 
DCFD(DCFDU)
用于为双精度的浮点数分配一片连续的字存储单元并用伪指令中指定的表达式初始化。
FDataTest  DCFD  2E115，-5E7 ；分配一片连续的字存储单元并初始化为指定的双精度数。
DCFS(DCFSU)
用于为单精度的浮点数分配一片连续的字存储单元并用伪指令中指定的表达式初始化。
FDataTest  DCFS  2E5，-5E－7 ；分配一片连续的字存储单元并初始化为指定的单精度数。
 
DCQ(DCQU)
用于分配一片以 8 个字节为单位的连续存储区域并用伪指令中指定的表达式初始化
DataTest  DCQ 100 ；分配一片连续的存储单元并初始化为指定的值。
 
SPACE
分配一片连续的存储区域并初始化为 0
DataSpace  SPACE  100 ；分配连续 100 字节的存储单元并初始化为0。
 
MAP
用于定义一个结构化的内存表的首地址
MAP 0x100，R0  ；定义结构化内存表首地址的值为 0x100＋R0。
 
FI LED
定义一个结构化内存表中的数据域
MAP 0x100  ；定义结构化内存表首地址的值为 0x100。
A  FIELD  16 ；定义 A 的长度为 16 字节，位置为 0x100
B  FIELD  32 ；定义 B 的长度为 32 字节，位置为 0x110
S  FIELD  256 ；定义 S 的长度为 256 字节，位置为 0x130
```