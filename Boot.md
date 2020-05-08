# Introduction #

Add your content here.


# 最小boot系统 #

  * init.c
```
volatile unsigned char * const UART0_PTR = (unsigned char *)0x0101f1000;
void display(const char *string){
    while(*string != '\0'){
        *UART0_PTR = *string;
        string++;
    }
}
 
int my_init(){
    display("Hello Open World\n");
}
```
  * startup.s
```
.global _Start
_Start:
LDR sp, = sp_top
BL my_init
B .
```
  * linker.ld
```
ENTRY(_Start)
SECTIONS
{
. = 0x10000;
startup : { startup.o(.text)}
.data : {*(.data)}
.bss : {*(.bss)}
. = . + 0x500;
sp_top = .;
}
```
  * compile all
```
$ arm-none-eabi-as  -mcpu=arm926ej-s startup.s -o startup.o
$ arm-none-eabi-gcc -c -mcpu=arm926ej-s init.c -o init.o
$ arm-none-eabi-ld -T linker.ld init.o startup.o -o output.elf
$ arm-none-eabi-objcopy -O binary output.elf output.bin
```
  * run
```
$ qemu-system-arm -M versatilepb -nographic -kernel output.bin
```
[For detail](http://www.linuxforu.com/2011/07/qemu-for-embedded-systems-development-part-2/)
# Todo #

[U-boot for ARM on QEMU](http://blog.chinaunix.net/uid-24404030-id-2609492.html)

[创建虚拟的U-boot和ARM Linux学习环境](http://blog.chinaunix.net/uid-24404030-id-2609494.html)