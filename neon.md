#What is Neon?
According to ARM, the Neon block of the Cortex-A8 core includes both the Neon and VFP accelerators. Neon is a SIMD (Single Instruction Multiple Data) accelerator processor integrated in as part of the ARM Cortex-A8. 
#What are the advantages of Neon
Aligned and unaligned data access allows for efficient vectorization of SIMD operations.
Support for both integer and floating point operations ensures adaptability to a broad range of applications, from compression decoding to 3D graphics.
Tight coupling to the ARM core provides a single instruction stream and a unified view of memory, presenting a single development platform target with a simpler tool flow.
The large Neon register file with its multiple views enables efficient handling of data and minimizes access to memory, enhancing data throughput performance.
[ref](http://processors.wiki.ti.com/index.php/Cortex-A8)

#Blit with neon
```
/*
*  Blit with NEON from RGBA8888 to YUV420SP.
* */
int NEONBlit(uint8_t *inrgb, uint8_t *outy, uint8_t *outuv, int32_t width_org, int32_t height_org, int32_t width_dst, int32_t height_dst)
{

    uint32_t i, j;
    uint8_t *argb_ptr = inrgb;
    uint8_t *y_ptr = outy;
    uint8_t *temp_y_ptr = y_ptr;
    uint8_t *uv_ptr = outuv;
    uint8_t *argb_tmpptr;
    uint8x8_t r1fac = vdup_n_u8(66);

    uint8x8_t g1fac = vdup_n_u8(129);
    ///////// uint8x8_t g11fac = vdup_n_u8(1);   ///////128+1 =129

    uint8x8_t b1fac = vdup_n_u8(25);
    uint8x8_t r2fac = vdup_n_u8(38);
    uint8x8_t g2fac = vdup_n_u8(74);
    uint8x8_t b2fac = vdup_n_u8(112);
    // int8x8_t r3fac = vdup_n_s16(112);
    uint8x8_t g3fac = vdup_n_u8(94);
    uint8x8_t b3fac = vdup_n_u8(18);

    uint8x8_t y_base = vdup_n_u8(16);
    uint8x8_t uv_base = vdup_n_u8(128);


    for (i=height_org; i>0; i-=2)    /////  line
    {
       for (j=(width_org>>3); j>0; j-=2)   ///// col
       {
           uint8_t y, cb, cr;
           int8_t r, g, b;
           uint8_t p_r[16],p_g[16],p_b[16];
           uint16x8_t temp;
           uint8x8_t result;
           uint8x8_t result_cr;
           uint8x8x2_t result_uv;


           // y = RGB2Y(r, g, b);
           uint8x8x4_t argb = vld4_u8(argb_ptr);
           temp = vmull_u8(argb.val[0],r1fac);    ///////////////////////y  0,1,2
           temp = vmlal_u8(temp,argb.val[1],g1fac);
           temp = vmlal_u8(temp,argb.val[2],b1fac);
           result = vshrn_n_u16(temp,8);
           result = vadd_u8(result,y_base);
           vst1_u8(y_ptr,result);     ////*y_ptr = y;


           argb_tmpptr= argb_ptr + 32;
           temp_y_ptr = y_ptr + 8;
           uint8x8x4_t argb1 = vld4_u8(argb_tmpptr);
           // y = RGB2Y(r, g, b);
           temp = vmull_u8(argb1.val[0],r1fac);    ///////////////////////y
           temp = vmlal_u8(temp,argb1.val[1],g1fac);
           temp = vmlal_u8(temp,argb1.val[2],b1fac);
           result = vshrn_n_u16(temp,8);
           result = vadd_u8(result,y_base);
           vst1_u8(temp_y_ptr,result);     ////*y_ptr = y;

           vst1_u8(p_r,argb.val[0]);
           vst1_u8(p_r+8,argb1.val[0]);
           vst1_u8(p_g,argb.val[1]);
           vst1_u8(p_g+8,argb1.val[1]);
           vst1_u8(p_b,argb.val[2]);
           vst1_u8(p_b+8,argb1.val[2]);
           uint8x8x2_t rgb_r = vld2_u8(p_r);
           uint8x8x2_t rgb_g = vld2_u8(p_g);
           uint8x8x2_t rgb_b = vld2_u8(p_b);

           //cb = RGB2CR(r, g, b);
           temp = vmull_u8(rgb_b.val[0],b2fac);    ///////////////////////cb
           temp = vmlsl_u8(temp,rgb_g.val[0],g2fac);
           temp = vmlsl_u8(temp,rgb_r.val[0],r2fac);
           result = vshrn_n_u16(temp,8);
           result = vadd_u8(result,uv_base);

           //cr = RGB2CB(r, g, b);
           temp = vmull_u8(rgb_r.val[0],b2fac);    ///////////////////////cr
           temp = vmlsl_u8(temp,rgb_g.val[0],g3fac);
           temp = vmlsl_u8(temp,rgb_b.val[0],b3fac);
           result_cr = vshrn_n_u16(temp,8);
           result_cr = vadd_u8(result_cr,uv_base);

           result_uv = vzip_u8(result_cr,result);  /////uuuuuuuuvvvvvvvv -->> uvuvuvuvuvuvuvuvuv
           vst1_u8(uv_ptr,result_uv.val[0]);
           uv_ptr += 8;
           vst1_u8(uv_ptr,result_uv.val[1]);
           uv_ptr += 8;

           argb_tmpptr= argb_ptr + (width_org<<2);
           temp_y_ptr = y_ptr + width_dst;
           argb = vld4_u8(argb_tmpptr);

           // y = RGB2Y(r, g, b);
           temp = vmull_u8(argb.val[0],r1fac);    ///////////////////////y
           temp = vmlal_u8(temp,argb.val[1],g1fac);
           temp = vmlal_u8(temp,argb.val[2],b1fac);
           result = vshrn_n_u16(temp,8);
           result = vadd_u8(result,y_base);
           vst1_u8(temp_y_ptr,result);   ////*y_ptr = y;


           argb_tmpptr =argb_ptr +( width_org<<2)+32;
           temp_y_ptr = y_ptr + width_dst + 8;
           argb = vld4_u8(argb_tmpptr);

           // y = RGB2Y(r, g, b);
           temp = vmull_u8(argb.val[0],r1fac);    ///////////////////////y
           temp = vmlal_u8(temp,argb.val[1],g1fac);
           temp = vmlal_u8(temp,argb.val[2],b1fac);
           result = vshrn_n_u16(temp,8);
           result = vadd_u8(result,y_base);
           vst1_u8(temp_y_ptr,result);     ////*y_ptr = y;

           y_ptr += 16;
           argb_ptr += 64;
       }

       y_ptr += width_dst;
       argb_ptr += width_org<<2;
    }

    return 0;
}

```