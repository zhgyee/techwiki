# FOV
![AngleOfView](/uploads/45509b60ad26e4e4e6f8f4af34fa6da9/AngleOfView.PNG)

# 水平FOV和垂直FOV

We need two different field of view angles (or zoom values), one horizontal
and one vertical. We are certainly free to choose any two arbitrary
values we fancy, but if we do not maintain a proper relationship between
these values, then the rendered image will appear stretched. If you’ve ever
watched a movie intended for the wide screen that was simply squashed
anamorphically to fit on a regular TV, or watched content with a 4:3 aspect
on a 16:9 TV in “full”8 mode, then you have seen this effect.

# Converting diagonal field of view and aspect ratio to horizontal and vertical field of view
![diagonal_fov_2](/uploads/97345c5cd3d24356cb945a365b20f62d/diagonal_fov_2.png)

The math is straightforward, but it involves a bit of trigonometry. Let’s take it step by step:
* If Df is the diagonal field of view and Ha:Va is the horizontal to vertical aspect ratio, we can find the corresponding diagonal size in the same units as the aspect ratio: 
`Da = sqrt(Ha*Ha + Va*Va)`
* The screen height and width are proportional to the tangent of the half angle. We use this to convert between field-of-view space and aspect-ratio space: 
`Da = tan(Df/2) and Df = atan(Da) * 2`
* If the tangent and arctangent functions operate in degrees, we get: 
`Hf = atan( tan(Df/2) * (Ha/Da) ) * 2`
Here the tan() function converts from FOV to aspect-ratio space, the ratio is scaled in that space and then converted back into FOV space.

# TV screen size vs. goggle field of view
The diagonal field of view is a function of S, the diagonal screen size and D, the viewing distance:
```
Field of View = 2 * arctan ( (S/2) / D )
```
Just make sure that S and D are using the same units and remember that most arctan functions return the value in radians, not degrees.
![fov_conversion](/uploads/019e0c09724731803406d33a7dd4e46f/fov_conversion.jpg)

# How binocular overlap impacts horizontal field of view
![overlap-for-16-9-aspect-ratio](/uploads/a5db1d296bd7fce8868e839899286de0/overlap-for-16-9-aspect-ratio.jpg)

![overlap-equations](/uploads/3becfa5fb18b6f0a3a15f705d2581e86/overlap-equations.jpg)



# FOV & Focal length
```
vertical field of view = 2 atan(0.5 height / focallength)
horizontal field of view = 2 atan(0.5 width / focallength)
```
# FOV and ZOOM
```
zoom = 1/tan(fov/2)
fov = 2*arctan(1/zoom)
```
zoom和FOV反相关，zoom变大，画面放大，FOV变窄。    
As zoom gets larger, the field of view gets smaller, causing the view frustum
to narrow. It might not seem intuitive at first, but when the view frustum
gets more narrow, the perceived size of visible objects increases.

# FOV的影响
* FOV变大看到的画面内容要多一些, 远一些, 小一些

可以用zoom或焦距来解释：更大的FOV，但相同的viewport，那投影面更接近针孔点，所以画面变小。    
In a physical camera, increasing the focal distance d while keeping the size of the
“film” the same has the effect of zooming in.
![focal](/uploads/02001236bf2ff3dddd3e2d5ff0e7492c/focal.PNG)
* FOV变大畸变会更大

# 光学FOV
下图是眼睛/屏幕/透镜的关系图, 由图可知视场角是`α*2`。    
![fov](/uploads/7b4853c1653bb75640001fbf478fddb6/fov.jpg)  
透镜其实就是放大镜，为何要放大？因为人有明视距离，太近的东西看不清楚。一般大于**25cm**的距离才能看清楚。想必你把手机直接放在你眼前5cm，你是看不清屏幕的东西吧。有人就要问了，那可以把手机放到25cm外呀？其实，那更不行了，25cm，意味着这个镜架的长度至少25cm了，这么大，戴到头上如何受得了！
 
既然是放大镜，那根据放大镜原理，屏幕必须放在焦距以内，才能放大。
放大以后，人眼看到的虚像位置，符合下面的公式：`1/u + 1/v = 1/f`
根据公式，假设焦距f=7cm, 物距(屏幕到透镜中心距离)u=6cm, 那么虚像位置就是42cm。满足人的明视距离大于25cm的要求。

现在VR设计，一般透镜在眼前1-1.5cm处，屏幕距透镜3-6cm，虚像成像在眼前25cm－50cm左右。
对于近视，像距需要变短，而物距(屏幕与透镜距离)一般做好了就无法改变，所以可以增大焦距f，即通过换透镜来改善。

此外，在设计VR时，在物距，焦距等几个参数的调整中，基本都是几毫米的微调，**需要权衡虚像距离过大（放大倍数大）而带来的像素颗粒感问题 和 虚像距离过近而带来的不够明视距离、视野较小等问题** 。

VR眼镜的结构：透镜+屏幕。
透镜其实就是放大镜，因为屏幕距离眼睛很近，小于25cm明视距离，所以需要透镜。
视场角就是透镜的一个参数，简单的说，它指的就是，通过透镜能看到的视野范围。

VR的透镜设计和屏幕选择，是一个相互影响的过程。
一般是先选好屏幕的尺寸大小，然后设计透镜(特别是设计其参数FOV，焦距等)，使其既能让视距大于25cm，又能让屏幕的边界刚好进入视场。

# VR中FOV的计算
* 屏幕的归一化半径 $`r_{sn}=r_s / w_s`$
* 虚像的归一化半径 $`r_{vn}=r_{sn}+k_{vs}r_{sn}^3`$
* 虚像半径 $`r_v=r_{vn}w_v`$
* 虚像中点的角度通过虚像半径与虚像距眼睛距离求得 $`\theta = arctan(r_v/z_v)`$
* 上下左右边角度可以通过$`\theta`$求得，$`\theta_T \theta_B \theta_L \theta_R`$
* single eye vertical field-of-view $`FOV_v=\theta_T + \theta_B`$
* single eye horizontal field-of-view $`FOV_h=\theta_L + \theta_R`$
* overlap fov $`FOV_{ov}=2\theta_{L}-\theta_{axes}`$
* binocular fov $`FOV_{bin}=2\theta_{R}+\theta_{axes}`$
 
示例及详细请参考《A Computational Model for the Stereoscopic Optics of a Head-Mounted Display》

# 每度像素 pixels-per-degree (PPD）
根据Wikipedia上对Retina Display的描述，乔布斯在发布iPhone4时首次提出了Retina显示屏的概念：
显示屏的分辨率如果达到300PPI时，也就是300pixel/inch时，把手机在人眼前10~12英寸距离时，人类的视网膜是无法分辨出屏幕上的像素颗粒的，这种屏幕就是Retina Display
如果用“每度像素”pixels-per-degree (PPD）描述，也就是`PPD(pixels/digree)=3DRtan(0.5)`
其中`D=屏幕到眼睛的距离`, `R=屏幕分辨率`
针对RetinaDisplay，`PPD=2*300*11*tan(0.5)=57.6`    
![ppd](/uploads/e8073780656357e97979cd529149a8fb/ppd.jpg)


# 纱门效应(像素感，纱窗效应)

# 分离式闪烁(sparkle distractingly)
这种纱门效应是由像素不足的情况下，实时渲染引发的细线条舞动、高对比度边缘出现分离式闪烁（sparkle distractingly）。

当前VR每度只有13-14个像素，会让VR中有很强的锯齿（aliasing）,从而产生了很粗糙的边缘。又因为VR是实时渲染的，所以当你的头微微转动时，你感觉那条原本应该静止的细线（或者某些物体的边缘线）像在闪烁或者舞动一般。

而对比度很高的物体边缘会出分离式闪烁（sparkle distractingly）——你会看到一个像素在RGB几种高纯度颜色之间闪烁，特别是你用了抗锯齿（anti-alisaing）的时候，这种闪烁加剧。

想到的一些解决方法：
其实我们只有视觉中心是清晰的，视觉外围的东西是模糊的。（流媒体VR视频中，根据你的视角而加载相应的画面、模糊不相关的画面，具体是如何实现的？ ）
但是其实像素还得在那里，不然用户不转头只转动眼珠，发现周围东西是模糊的怎么办？所以想降低这个要求还得结合眼球追踪实时渲染技术或是有望十年后的光场视网膜投影技术？（除了光场，还有什么方式能解决VR显示的accommodation-vergence conflict？）

# 理想的VR分辨率
每个人的视场角都有些许差距，但大多都是水平210°，垂直100°。
pixel per degree（像素每度）——是指一度所包含的像素。
我们在3米距离内看电视、半米距离内操作电脑、一尺距离内玩手机，为什么看不出像素呢？
因为你视场角中的1°会看到60个像素，从而分辨不出像素感，60°才能达到『视网膜』级别的体验。
在下图中，每个格子代表水平视场角上的1°和垂直视场角上的1°的小方格。如果每一度上有60个像素，那么一个小方格是60×60个像素。

# 视场角能不能做得更大？

答案当然是能，为了得到更宽广的视场，你需要缩短与透镜间的距离，或增加透镜的大小。但这又将带来诸多其他弊端。    
缩短与透镜间的距离，需要采用厚透镜，但透镜与眼睛的距离又可能太近。这里可能有 三大问题，
* 一是成像于视网膜前，由于人的晶状体不是凹透镜，人根本看不清楚画面；
* 二是即使还能看见，但放大倍率太高，屏幕的晶格感会更加严重；
* 三是可能会造成眼睛或镜片的损伤。

当然可使用直径较大的透镜增加视场，但也会面临一些新的挑战。大透镜的中间也会比较厚，重量也会随之增加。这个问题可以通过菲涅尔透镜解决。但第二个问题是不管使用哪种类型的透镜，大透镜都会带来更多的光学像差。

当然，还有另外一个问题，那就是手机屏幕的限制，如下图：    
![](http://cn.technode.com/files/2016/05/%E6%9C%AA%E6%A0%87%E9%A2%98-1.jpg)

由上图可知，对与固定尺寸的屏幕而言，并不是视场角越大越好，如果过大，则会看见屏幕边缘，而且会有画面显示不全的现象，沉浸感也便会大打折扣。

# FOV计算

可以参考stanford教程

# ref
[如何看待 PSVR 100度的可视角度？](https://www.zhihu.com/question/41515018)    
[理想的VR头显需要达到多少分辨率，才能消除纱门效应？](https://www.zhihu.com/question/39696826)    
[浅析VR透镜与视场角](http://mp.weixin.qq.com/s?__biz=MzAxNDk2NTE1NA==&mid=100000015&idx=1&sn=8ec0b4fdbb5f902c29f7f12da22713dc#rd)