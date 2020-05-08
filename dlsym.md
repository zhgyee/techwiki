# Introduction #

从模块的symtab中查找相应的名称，并返回对应的addr

# Details #

在\_load\_shared\_object中，先动态分配symtab(符号表)，建立符号表项，记录符号的地址和名称
```
            module->symtab[count].addr = 
                (void *)(module->module_space + symtab[i].st_value);
            module->symtab[count].name = rt_malloc(length);
            rt_memset((void *)module->symtab[count].name, 0, length);
            rt_memcpy((void *)module->symtab[count].name, 
                strtab + symtab[i].st_name, length);

```
然后在dlsym中可以直接根据名称查找.