#platform_get_resource
```
#define IORESOURCE_IO       0x00000100  /* PCI/ISA I/O ports */
#define IORESOURCE_MEM      0x00000200
#define IORESOURCE_REG      0x00000300  /* Register offsets */
#define IORESOURCE_IRQ      0x00000400
#define IORESOURCE_DMA      0x00000800

platform_get_resource(pdev, IORESOURCE_IRQ, 0);
platform_get_resource_byname

```
#ioremap
```
    io_data->len = (u32)resource_size(res);
    io_data->base = ioremap(res->start, io_data->len);
```