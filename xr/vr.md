# VR 相关技术
![vr tree](/img/VR_tree.PNG)

# VR 相关数据
* 最低头部转动到转动画面的显示延迟在20ms以内，假设头部转动速度为100度/秒，20ms延迟对应视野中物体转动的延迟约为2度。
* 90%的人瞳距在60-70mm范围，瞳距会影响人眼的对焦。
* 人眼视野范围水平角度124度，垂直角度120度，两眼综合的视角约为170度。面对正前方，15度为辨识区域，可明确辨识物体，15-30度为可视区域，可看清物体存在，超过30度为余光。![另一说](https://pic4.zhimg.com/c1f0a4c6597808d6f5ae43eef33281bb_b.jpg)
* 人眼像素间距(pixel space)为0.39角分（1度=60角分=3600角秒），假设视野120x120，所需要的分辨率为(120x60/0.3)^2=576万像素，1080pHD屏幕才207万像素，只有4K屏才接近人眼极限。
* FOV越大，则放大倍数也越大。
* oculus建议刷新率为75hz以上

# VR latency
VR设备的时延主要取决于四大因素：
 * 显示延时
  * 帧间延时---提高刷新率
  * 帧内延时---降低屏幕响应时间、降低余晖
 * 计算延时
 * 传输延时
 * 传感器延时

# VR wiki
XinReality is a VR and AR Wiki. Our mission is to collect, clarify and consolidate any and every bit of information related to virtual reality and augmented reality. 
[xinreality](http://xinreality.com/wiki/Category:Terms)
# VR晕动症
研究发现，用户之所以会出现晕动症，是因为内耳前庭系统的物理运动信号与虚拟现实设备产生的虚拟运动信号之间的冲突。缩小用户的视场可以帮助减少恶心的情况，但这样会造成沉浸感的损失。而哥伦比亚大学研发出了一个软件，系统会依据实际情况对用户视场进行细微调节，减少两种信号之间的冲突。
# vr performance
 * There is also a small amount of overhead involved in putting the final output frame together with distortion and TimeWarp (budget for 2 ms)
 * VR rendering throws hardware performance characteristics into sharp relief because every frame must be drawn twice, once for each eye.That means that some of the most expensive parts of the graphics pipeline cost twice as much time in VR as they would in a flat game.
 * low pixel persistence, to avoid blurring with eye motion--(no more than 3ms).We’ve found that persistence of 3 ms or less is required for presence with a 1K x 1K, 110-degree
head-mounted display. Shorter persistences will be required at higher pixel densities.
 * resolution--We’ve found that 1080p seems to be enough for presence.We expect that 1440p, or better yet 2160p would be huge steps up
 * field of view-- Presence starts to work somewhere around an 80 degree field of view, and improves significantly at least out to 110 degrees, which is the widest we’ve tested.
 * refresh rate--95hz seems to be sufficient. A somewhat lower refresh rate may be adequate,but we haven’t done the experiments yet.
 * optical
 * traking-- We’ve found that we can get presence with tracking accuracy of a millimeter in position and a quarter-degree in orientation, maintained over a volume no smaller than a meter and a half on a side.
 * latency--We’ve found that latency of 20 ms, combined with good prediction, works well, and it’s possible that latency up to 25 ms may be adequate.

# Motion-To-Photon Latency 物理运动到光学显示时延
Motion-to-Photon latency is the time needed for a user movement to be fully reflected on a display screen. If it takes 100ms to reflect your movements on the screen of your virtual reality headset when you make a movement (e.g. look to the left), the 100ms is the motion-to-photon latency.
![motion to photon](http://www.chioka.in/wp-content/uploads/2015/03/Motion-to-Photons-Latency.png)

# VR processing model 
The classic processing model for a game or VR application is:
Read user input -> run simulation -> issue rendering commands -> graphics drawing -> wait for vsync -> scanout
 * Read user input (I)
 * Run simulation (S)
 * Issue rendering commands (R)
 * Graphics drawing (G)
 * Wait for Vsync (The ‘|’)
 * Scanout (V)

![Courtesy of John Carmack from “Latency Mitigation Strategies”](http://www.chioka.in/wp-content/uploads/2015/03/render_pipeline_basic.png)
![Prevent GPU Buffering](http://www.chioka.in/wp-content/uploads/2015/03/render_pipeline_no_gpu_buffering1.png)
![Timewarping ](http://www.chioka.in/wp-content/uploads/2015/03/render_pipeline_timewarping.png)

[What is Motion-To-Photon Latency](http://www.chioka.in/what-is-motion-to-photon-latency/)

[Latency Mitigation Strategies](https://web.archive.org/web/20140719053303/http://www.altdev.co/2013/02/22/latency-mitigation-strategies/)

# graphic batching
we can actually wrap multiple meshes up into a single large array of verts and draw them individually out of the same vertex buffer object. We pay the selection cost for the whole mesh once, then issue as many draw calls as we can from meshes contained within that object. This trick, called batching, is much faster than creating a unique VBO for each mesh, and is the basis for almost all of our draw call optimization.

All of the meshes contained within a single VBO must have the same material settings for batching to work properly: the same texture, the same shader, and the same shader parameters. To leverage batching in Unity, you actually need to go a step further: objects will only be batched properly if they have the same material object pointer.

# Perception of stationarity
The short amount of time
that the display is illuminated is sufficient for the photoreceptors to collect enough
photons to cause the image to be perceived. The problem is that at 60 FPS in
low-persistence mode, flicker is perceived, **which can lead to fatigue or headaches**.
This can be easily perceived at the periphery in a bright scene in the Samsung Gear
VR headset. If the frame rate is increased to 90 FPS or above, then the adverse
side effects of flicker subside for nearly everyone. If the frame rate is increased to
500 FPS or beyond, then it would not even need to flicker


# performance hint
 * 50 – 100 draw calls per frame
 * 50k – 100k polygons per frame
 * As few textures as possible (but they can be large)
 * 1 ~ 3 ms spent in script execution (Unity Update())
 * API for throttling the CPU and GPU to control heat and battery drain.These methods allow you to choose whether the CPU or GPU is more important for your particular scene.If your game is CPU-bound, you can downclock the GPU in order to run the CPU at full speed. If your app is GPU-bound you can do the reverse. 
 * design your art to require as few draw calls as possible. A draw call is a command to the GPU to draw a mesh or a part of a mesh.
 * the driver has CPU work to do every time a new mesh is selected. It is this selection process that incurs the most overhead when issuing a draw call.
 * However, that also means that once a mesh (or, more specifically, a vertex buffer object, or VBO) is selected, we can pay the selection cost once and draw it multiple times. As long as no new mesh (or shader, or texture) is selected, the state will be cached in the driver and subsequent draw calls will issue much more quickly
 * fill-bound,meaning that the cost of filling pixels can be the most expensive part of the frame. The key to reducing fill cost is to try to draw every pixel on the screen only once.The cost here is touching pixels, so the fewer pixels you touch, the faster your frame can complete.


# reference
[Latency – the sine qua non of AR and VR](http://blogs.valvesoftware.com/abrash/latency-the-sine-qua-non-of-ar-and-vr/)

[Optimizing VR Graphics with Late Latching](https://developer.oculus.com/blog/optimizing-vr-graphics-with-late-latching/)

[Squeezing Performance out of your Unity Gear VR Game](https://developer.oculus.com/blog/squeezing-performance-out-of-your-unity-gear-vr-game/)

[Abrash dev days](http://media.steampowered.com/apps/abrashblog/Abrash%20Dev%20Days%202014.pdf)