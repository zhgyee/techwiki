# 常用工具及功能
## 静态分析工具
### eclipse
  java,c/c++ IDE开发环境，可以通过eclipse查看以下代码静态逻辑：
 * Call Hierarchy 静态调用关系分析，可以获取函数静态调用关系图
 * Type Hierarchy 类型派生层级图，可以看到类的继承关系图

### doxygen
 比较适合C语言静态分析，可以生成调用或被调用关系图，以及数据结构关系图。

### visual paradigm
 可以逆向java/c++工程，生成uml类图

## 动态分析工具
### traceview
android上java代码的性能分析工具，当然也可以作为代码分析工具。
### systrace
很好的代码动态分析工具，可以针对android/chrome等运行时trace生成关键路径，当然需要在代码中预添加相应的trace tag
### gdb
在android 工程下运行gdbclient就可以进行gdb调试，通过断点、bt等完成相要的目标
### profile类工具
profile工具是要分析运行时性能热点，当然也可以做为代码分析的工具了
 * oprofile
 * mali streamline

# 分析方法
## systrace+eclipse
从systrace可以看到一些关键路径点，然后在eclipse中找出关键路径点，并使用call hierarchy查看静态调用栈

## reverse+uml
通过vp/doxygen生成类图和时序图
