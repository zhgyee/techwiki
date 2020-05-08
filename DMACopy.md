# Introduction #

# Details #
##  映射内存 ## 
```
    dma_lli_phy     DMA链表存放物理位置,可以通过mmz分配或直接从/dev/mem中分配
    dma_reg_phy 0x60030000    DMA寄存器物理地址
    clock_reg_phy 0x101f5000  DMA clock寄存器物理地址
		映射dma寄存器
    通过 mmap的方法将物理地址map的虚地址,这时应用程序才可以操作寄存器,map的参数为: PROT_READ|PROT_WRITE, MAP_SHARED
		映射dma时钟,参数为
    PROT_READ|PROT_WRITE, MAP_SHARED
```
##  初始化DMA链表 ## 
```
如果要拷贝384块内存,则每一块都要建立链表,链表entry配置如下:
Byte 0:源块物理地址
Byte 1:目标块物理地址
Byte 2:下一个dma链表entry地址，如dma_lli_phy + 16 + i*16，DMA链表一个为16字节
Byte 3: DMA配置，如0x0f49202f表示内存到内存，4字节位宽，burst为8，47*4=188字节
最后一个DMA链表的entry内容如下：
Byte 2：为0, last lli point to 0
Byte 3: 0x8f48002f;  last lli enable intr

```