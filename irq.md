# affinity
/proc/irq/IRQ#/smp_affinity and /proc/irq/IRQ#/smp_affinity_list specify which target CPUs are permitted for a given IRQ source. 
```
# set gpu irq affinity to core 1~3
 echo e> /proc/irq/273/smp_affinity 
 cat /proc/irq/273/smp_affinity
```