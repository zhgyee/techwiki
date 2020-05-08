# PPI
Samsung 2.5K Quad HD 2560x1440 Display, Rendering with 577 pixels per inch (ppi)    
AUO 2160x1200 434ppi
# Mura校正
Mura描述的是相邻像素之间色彩和亮度的差异。如果你将整个屏幕设置为蓝色，屏幕亮度均匀意味着每个像素都已相同的蓝色和亮度发光。当一个像素和相邻的像素颜色和亮度产生明显差异时，我们称之为Mura。这种效果通常是一种云的形状的网格，就像你的眼前有一块薄薄的纱布一样。
# AMOLED余晖问题
OLED的屏需要让供应商去做插黑，才能解决余辉问题
因为像素从黑到白的响应时间最长，所以拖影和余晖问题取决于此最长响应时间。
# 蓝光问题
AMOLED 由于其有机自发光特性，白光是透过 RGB 混合调配出来的，而不是像一般 LED 背光直接使用蓝光波长透过染料去激发白光，所以蓝光强度比 LCD 面板常用的 LED 背光低了不少，对眼睛的伤害也比较低。
就说日常的LED灯，众所周知LED中是没有白光的，所谓的白光只不过是用蓝光加黄色荧光粉形成的。
# display pipeline
display soc在硬件上，从framebuffer到panel的video stream流会经过一条pipeline，这条pipeline一般由plane，controller，encoder，panel组成。最前端的plane为多个head的机制提供了单独的framebuffer支持，不同的plane（图层）可以接入不同的display device如hdmi，dsi，vga显示不同的内容；controller负责从framebuffer中的指定区域读取像素，驱动各种需要的PLL，时钟（pixel clock等），如果controller支持多个overlay，controller还要管理overlay的叠加工作；encoder负责将并行的pixel/clock信号转换为终端显示设备需要的串行信号等如DSI，HDMI，最后的panel则是接收输入的pixel/clock信号驱动行列驱动器在玻璃上‘显示’图像，如图：
```
+-------------------------------------------------+
| +------------+   +-----------+   +------------+ | +-----------+
| |            |   | Display   |   | Encoder    | | |           |
| | Plane      +---+ Controller+---+ (HDMI,DSI) +-+-+  Panel    |
| |            |   |           |   |            | | |           |
| +------------+   +-----------+   +------------+ | +-----------+
+-------------------------------------------------+ 
```           
这些block除了最后的panel属于external device以外，其他都以ip的形式集成到主控制器的soc里了，同一系列的芯片不同版本的soc可能只是对不同版本的ip block的组合而已，所以，为了代码复用，一般soc vendor的driver在设计时为每个block都设计了自己的驱动对象struct device_driver和由该驱动管理的设备类struct deice的定义，具体的设备实例然后被板级的bringup code动态地‘注册’进系统，driver在probe它们时为其分配必要的资源和注册各自的hook callback函数，比如响应上面的用户对blank属性设置的请求的on/off函数。pipeline也决定了控制函数的调用顺序，比如on/off处理函数，在on系统请求被调用时，就要先调用最上级的plane_on_callback，最后调用最下级的panel_on_callback；如果是off系统请求时，顺序就完全相反。

## DECON functions
* Composites input images
* Optionally enhances and compresses composited images
* Generates video timing signals such as VSYNC, HSYNC, DE


# Display Technology
## post-processing
Modern displays are also expected to perform a wide variety of processing on the incoming signal before they change the actual display elements.  A typical Full HD display today will accept 720p or interlaced composite signals and convert them to the 1920x1080 physical pixels.  24 fps movie footage will be converted to 60 fps refresh rates.  Stereoscopic input may be converted from side-by-side, top-down, or other formats to frame sequential for active displays, or interlaced for passive displays.  Content protection may be applied.  Many consumer oriented displays have started applying motion interpolation and other sophisticated algorithms that require multiple frames of buffering. 

**Some of these processing tasks could be handled by only buffering a single scan line, but some of them fundamentally need one or more full frames of buffering, and display vendors have tended to implement the general case without optimizing for the cases that could be done with low or no delay.  Some consumer displays wind up buffering three or more frames internally, resulting in 50 milliseconds of latency even when the input data could have been fed directly into the display matrix.** - See more at: https://web.archive.org/web/20140719053303/http://www.altdev.co/2013/02/22/latency-mitigation-strategies/#sthash.JqdNiA89.dpuf

A subtle latency point is that most displays present an image incrementally as it is scanned out from the computer, which has the effect that the bottom of the screen changes 16 milliseconds later than the top of the screen on a 60 fps display.  This is rarely a problem on a static display, but on a head mounted display it can cause the world to appear to shear left and right, or “waggle” as the head is rotated, because the source image was generated for an instant in time, but different parts are presented at different times.  This effect is usually masked by switching times on LCD HMDs, but it is obvious with fast OLED HMDs. - See more at: https://web.archive.org/web/20140719053303/http://www.altdev.co/2013/02/22/latency-mitigation-strategies/#sthash.JqdNiA89.dpuf

## Pixel Fill Factor
![Pixel Fill Factor](https://ksr-ugc.imgix.net/assets/001/126/559/e6412809759554c18d335384262a5fd4_original.png?v=1381666917&w=639&fit=max&auto=format&lossless=true&s=115933bb7ec56f8b9bf5ba6314e0ba01)

## Pixel Switching Time
Pixel Switching Time is the amount of time required for a pixel to switch from one color to another. switching colors very quickly, which was good, since it reduced the latency between movement and the image responding. However, it’s weakness was that it took a very long time to fully switch colors. This sometimes resulted in motion-blur effect as the frames switched, especially during quick movements of the head.
![pixel switching](http://www.chioka.in/wp-content/uploads/2015/03/pixel_switching_time.png)
In this example, the pixel switching time for this (3 x 3) display is 3ms. This is because it takes 1ms to update one line of pixels and 3 updates to update the whole display.
LCD displays have poor pixel switching time. Other technologies like OLED provide almost instantaneous response time.
## Refresh Rate
The refresh rate is the frequency the display fetches a new image to be drawn from the graphics card, which determines how long the latency to wait between each image. For a 60Hz display, the latency is calculated as (1000ms / 60Hz =) 16.67ms. This means even if the image takes zero latency to be drawn at the graphics card, and have zero pixel switching time, the image can only be updated as fast as 1 image every 16.67ms.

To decrease latency of getting an image, a higher refresh rate display is needed because latency (ms) = 1000ms / refresh rate (Hz). For instance, a 120Hz will decrease this latency to 8.33ms.


## Raster scanning
Raster scanning is the process of displaying an image by updating each pixel one after the other, rather than all at the same time, with all the pixels on the display updated over the course of one frame. **Now days the raster scan reflects the order in which pixel data is scanned out of the graphics adapter and into the display**. 

It’s necessary that pixel data be scanned into the display in some time-sequential pattern, because the video link (HDMI, for example) transmits pixel data in a stream. However, it’s not required that these changes become visible over time. It would be quite possible to scan in a full frame to, say, an LCD panel while it was dark, wait until all the pixel data has been transferred, and then illuminate all the pixels at once with a short, bright light, so all the pixel updates become visible simultaneously.

related potential solution: increase the speed of scan-out and the speed with which displays turn streamed pixel data into photons without increasing the frame rate. For example, suppose that a graphics chip could scan-out a frame buffer in 8 ms, even though the frame rate remained at 60 Hz; scan-out would complete in half the frame time, and then no data would be streamed for the next 8 ms. If the display turns that data into photons as soon as it arrives, then overall latency would be reduced by 8 ms, even though the actual frame rate is still 60 Hz. And, of course, the benefits would scale with higher scan-out rates. This approach would not improve perceived display quality as much as higher frame rates, but neither does it place higher demands on rendering, so no reduction in rendering quality is required. Like higher frame rates, though, this would only benefit AR/VR, so it is not going to come into existence in the normal course of the evolution of display technology.[ref](http://blogs.valvesoftware.com/abrash/latency-the-sine-qua-non-of-ar-and-vr/)

![Raster scanning](http://media.steampowered.com/apps/abrashblog/blog8_fig1.png)

[Raster-Scan Displays: More Than Meets The Eye](http://blogs.valvesoftware.com/abrash/raster-scan-displays-more-than-meets-the-eye/)

## raster scan
the raster scan reflects the order in which pixel data is scanned out of the graphics adapter and into the display. There’s no reason that the scan-in has to proceed in that particular order, but on most devices that’s what it does, although there are variants like scanning columns rather than rows, scanning each pair of lines in opposite directions, or scanning from the bottom up. If you could see events that happen on a scale of milliseconds (and, as we’ll see shortly, under certain circumstances you can), you would see pixel updates crawling across the screen in raster scan order, from left to right and top to bottom.

It’s necessary that pixel data be scanned into the display in some time-sequential pattern, because the video link (HDMI, for example) transmits pixel data in a stream. However, it’s not required that these changes become visible over time. It would be quite possible to scan in a full frame to, say, an LCD panel while it was dark, wait until all the pixel data has been transferred, and then illuminate all the pixels at once with a short, bright light, so all the pixel updates become visible simultaneously. I’ll refer to this as **global display**, and, in fact, it’s how some LCOS, DLP, and LCD panels work.

your perception will be based on whatever pattern is actually produced on your retina by the photons emitted by the image.
the eye is smoothly tracking the image, so it’s moving to the right at 60 degrees/second relative to the display. (Note that 60 degrees/second is a little fast for smooth pursuit without saccades, but the math works out neatly on a 60 Hz display, so we’ll go with that.) The topmost pixel in the vertical line is displayed at the start of the frame, and lands at some location on the retina. Then the eye continues moving to the right, and the raster continues scanning down. By the time the raster reaches the last scan line and draws the bottommost pixel of the line, it’s something on the order of 15 ms later, and here we come to the crux of the matter – the eye has moved about one degree to the right since the topmost pixel was drawn. (Note that the eye will move smoothly in tracking the line, even though the line is actually drawn as a set of discrete 60 Hz samples.)
![Figure 4](http://media.steampowered.com/apps/abrashblog/blog8_fig4.png)
Note that for clarity, Figure 4 omits the retinal image flipping step and just incorporates its effects into the final result. The slanted pixels are shown at the locations where they’d be perceived; the pixels would actually land on the retina offset in the opposite direction, and reversed vertically as well, due to image inversion, but it’s the perceived locations that matter.

## VSync
All the drawing was done immediately after vsync;
If your monitor is set at a specific refresh rate, it always updates the screen at that rate, even if nothing on it is changing. On an LCD, things work differently. Pixels on an LCD stay lit until they are told to change; they don't have to be refreshed. However, because of how VGA (and DVI) works, the LCD must still poll the video card at a certain rate for new frames. This is why LCD's still have a "refresh rate" even though they don't actually have to refresh.

VSync solves this problem by creating a rule that says the back buffer can't copy to the frame buffer until right after the monitor refreshes. With a framerate higher than the refresh rate, this is fine. The back buffer is filled with a frame, the system waits, and after the refresh, the back buffer is copied to the frame buffer and a new frame is drawn in the back buffer, effectively capping your framerate at the refresh rate.
[how-vsync-works-and-why](http://hardforum.com/threads/how-vsync-works-and-why-people-loathe-it.928593/)

# render buffer
## Double-buffering
Double-buffering is a technique that mitigates the tearing problem somewhat, but not entirely. Basically you have a frame buffer and a back buffer. Whenever the monitor grabs a frame to refresh with, it pulls it from the frame buffer. The video card draws new frames in the back buffer, then copies it to the frame buffer when it's done. However the copy operation still takes time, so if the monitor refreshes in the middle of the copy operation, it will still have a torn image.

In double buffering 1 frame is written to the backbuffer and then flipped over to the front buffer when it is rendered and scanned out through the DAC.
VSync solves this problem by creating a rule that says the back buffer can't copy to the frame buffer until right after the monitor refreshes. With a framerate higher than the refresh rate, this is fine. The back buffer is filled with a frame, the system waits, and after the refresh, the back buffer is copied to the frame buffer and a new frame is drawn in the back buffer, effectively capping your framerate at the refresh rate.

Essentially this means that with double-buffered VSync, the framerate can only be equal to a discrete set of values equal to Refresh / N where N is some positive integer. That means if you're talking about 60Hz refresh rate, the only framerates you can get are 60, 30, 20, 15, 12, 10, etc etc. You can see the big gap between 60 and 30 there. Any framerate between 60 and 30 your video card would normally put out would get dropped to 30.

## triple-buffering
There is a technique called triple-buffering that solves this VSync problem. Lets go back to our 50FPS, 75Hz example. Frame 1 is in the frame buffer, and 2/3 of frame 2 are drawn in the back buffer. The refresh happens and frame 1 is grabbed for the first time. The last third of frame 2 are drawn in the back buffer, and the first third of frame 3 is drawn in the second back buffer (hence the term triple-buffering). The refresh happens, frame 1 is grabbed for the second time, and frame 2 is copied into the frame buffer and the first part of frame 3 into the back buffer. The last 2/3 of frame 3 are drawn in the back buffer, the refresh happens, frame 2 is grabbed for the first time, and frame 3 is copied to the frame buffer. The process starts over. This time we still got 2 frames, but in only 3 refresh cycles. That's 2/3 of the refresh rate, which is 50FPS, exactly what we would have gotten without it. Triple-buffering essentially gives the video card someplace to keep doing work while it waits to transfer the back buffer to the frame buffer, so it doesn't have to waste time. Unfortunately, triple-buffering isn't available in every game, and in fact it isn't too common. It also can cost a little performance to utilize, as it requires extra VRAM for the buffers, and time spent copying all of them around. However, triple-buffered VSync really is the key to the best experience as you eliminate tearing without the downsides of normal VSync (unless you consider the fact that your FPS is capped a downside... which is silly because you can't see an FPS higher than your refresh anyway).

## Front Buffer Rendering
a single buffer that you can render to while it is being scanned to the screen. To avoid tear lines, it is up to the application to draw only in areas of the window that aren't currently being scanned out.
[ref](https://developer.oculus.com/documentation/mobilesdk/latest/concepts/mobile-frontbufferrendering/)

