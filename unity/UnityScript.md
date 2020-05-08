# unity 线程模型
脚本线程,所有脚本的接口都在脚本线程中执行，脚本生命周期都是在脚本线程中执行
渲染线程，执行渲染命令，可以通过CommandBuffer.IssuePluginEvent或GL.IssuePluginEvent发送命令，让渲染线程执行

* unity main线程
* unity rendering线程

# Script Lifecycle Flowchart
![Script Lifecycle Flowchart](https://docs.unity3d.com/uploads/Main/monobehaviour_flowchart.svg)


# Materail
# Physicals
## Rigid body
* AddForce()

## Colider

# MonoBehaviour 接口
A script makes its connection with the internal workings of Unity by implementing a class which derives from the built-in class called MonoBehaviour. You can think of a class as a kind of blueprint for creating a new Component type that can be attached to GameObjects. Each time you *attach a script component to a GameObject*, it creates a new instance of the object defined by the blueprint. The name of the class is taken from the name you supplied when the file was created. The class name and file name must be the same to enable the script component to be attached to a GameObject.    
简单说就是绑定到GameObject后，GameObject调用MonoBehaviour的接口
## Update()
Update is called before the frame is rendered and also before animations are calculated.
## FixedUpdate()
FixedUpdate()以固定的频率刷新，而update是以帧率为准，所以存在不规律的情况。FixedUpdate()可以单独设置刷新率。    
The physics engine also updates in discrete time steps in a similar way to the frame rendering. A separate event function called FixedUpdate is called just before each physics update. Since the physics updates and frame updates do not occur with the same frequency, you will get more accurate results from physics code if you place it in the FixedUpdate function rather than Update.
## LateUpdate()
It is also useful sometimes to be able to make additional changes at a point after the Update and FixedUpdate functions have been called for all objects in the scene and after all animations have been calculated.
## MonoBehaviour.OnRenderObject()

OnRenderObject is called after camera has rendered the scene.

This can be used to render your own objects using Graphics.DrawMeshNow or other functions. 
This function is similar to OnPostRender, except OnRenderObject is called on any object that has a script with the function; 
no matter if it's attached to a Camera or not.

# Scriptable Render Loops
unity5.6以后版本的扩展，提供c++ core部分和c#用户层部分，其中c#部分开源，方便开发者修改和定制。


# Post-Processing Effects
Post-processing is a way of applying effects to rendered images in Unity.

Any Unity script that uses the OnRenderImage function can act as a post-processing effect. Add it to a Camera GameObject for the script to perform post-processing.

see [unity manu](https://docs.unity3d.com/Manual/PostProcessingWritingEffects.html)

## MonoBehaviour.OnRenderImage(RenderTexture,RenderTexture)
```
var mat: Material;

function OnRenderImage(src: RenderTexture, dest: RenderTexture) {
    // Copy the source Render Texture to the destination,
    // applying the material along the way.
    Graphics.Blit(src, dest, mat);
}
```
# RequireComponent
The RequireComponent attribute automatically adds required components as dependencies.    
加载依赖组件，然后可以通过rb = GetComponent<XXX>();获取组件实例

# coroutine 协程
When you're creating a coroutine in Unity, what you're really doing is creating an iterator. 
When you pass it to the StartCoroutine method, it will get stored and gets asked for its next item every frame, until it is finished.

The yield statements produce the items. The statements in between – the stuff that you want to happen – are side-effects of the iterator doing its job.

You can yield special things like WaitForSeconds to have more control over when your own code continues, but the overall approach is simply that of an iterator.
## What's an enumerator?
Enumeration is the concept of going through some collection one item at a time, like looping over all elements in an array. 
An enumerator – or iterator – is an object that provides an interface for this functionality. System.Collections.IEnumerator describes such an interface.

## WaitForEndOfFrame
Waits until the end of the frame after all cameras and GUI is rendered, just before displaying the frame on screen.    
用来做帧同步，比如WaitForEndOfFrame等待一帧结束，然后做后处理，如timewarp/distortion等。
