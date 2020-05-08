# arm & thumb 指令集
ARM指令格式如下
```
{opcode}{<cond>}{S}{.W|.N}<Rd>,<Rn>{,<oprand2>}
opcode-指令助记符
cond-执行条件
S-是否影响CPSR
.W .N 指令宽度说明
```
* B/BL/BX/BLX. L-LR X-thumb状态切换
* LDR{B/SB/H/SH}/LDRD. B-byte H-half word D-double word 
* STR/STRD
* LDM{IA/IB/DA/DB/FD/FA/ED/EA} I-increase D-decrease A-after B-before F-full E-empty !-地址回写
* STM
* PUSH/POP/SWAP

#do not support thumb/arm mode
```
#This needs to be defined to avoid compile errors like:
#Error: selected processor does not support ARM mode `ldrex r0,[r3]'
APP_ABI 		:= armeabi-v7a
```