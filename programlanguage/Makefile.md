# Introduction #

Add your content here.

# functions #

```
 $(function arguments)
```
https://www.gnu.org/software/make/manual/html_node/Functions.html#Functions

# Text-Functions #
```
$(subst from,to,text)
```
https://www.gnu.org/software/make/manual/html_node/Text-Functions.html#Text-Functions

# foreach #

```
$(foreach var,list,text)
dirs := a b c d
files := $(foreach dir,$(dirs),$(wildcard $(dir)/*))
```

https://www.gnu.org/software/make/manual/html_node/Foreach-Function.html

# wildcard
通配符会被自动展开，如获取工作目录下的所有的.c文件列表：
```
$(wildcard *.c)
```
We can change the list of C source files into a list of object files by replacing the ‘.c’ suffix with ‘.o’ in the result, like this:
```
$(patsubst %.c,%.o,$(wildcard *.c))
```