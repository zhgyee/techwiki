# 场景加载
* 使用单例模式加载场景，保证非当前场景不要被销毁
* 使用异步加载
* 使用loading场景过渡

参考：

* http://myriadgamesstudio.com/how-to-use-the-unity-scenemanager/
* https://github.com/MyriadGamesStudio/unity-examples/blob/master/Assets/SceneManager/Scripts/SceneLoaderAsync.cs

```
    public void LoadScene()
    {
        // kick-off the one co-routine to rule them all
        StartCoroutine(LoadScenesInOrder());
    }

    private IEnumerator LoadScenesInOrder()
    {
        // LoadSceneAsync() returns an AsyncOperation, 
        // so will only continue past this point when the Operation has finished
        yield return SceneManager.LoadSceneAsync("Loading");

        // as soon as we've finished loading the loading screen, start loading the game scene
        yield return StartCoroutine(LoadScene("Game"));
    }

    private IEnumerator LoadScene(string sceneName)
    {
        var asyncScene = SceneManager.LoadSceneAsync(sceneName);

        // this value stops the scene from displaying when it's finished loading
        asyncScene.allowSceneActivation = false;

        while (!asyncScene.isDone)
        {
            // loading bar progress
            _loadingProgress = Mathf.Clamp01(asyncScene.progress / 0.9f) * 100;

            // scene has loaded as much as possible, the last 10% can't be multi-threaded
            if (asyncScene.progress >= 0.9f)
            {
                // we finally show the scene
                asyncScene.allowSceneActivation = true;
            }

            yield return null;
        }
    }
```


# Native Plugin
## using delegate for callback
for those of you that may run across this in the future in the context of Unity 3D, 
here is an example native-code plugin and test Unity project which demonstrate callbacks, 
recurring callbacks, and simple byte marshaling from native code back to Unity/C#. It's pretty applicable to any kind of mono/C# integration, though.
https://github.com/natbro/UnityPlugin

Create a C# delegate for the function you want to call, and use Marshal.GetFunctionPointerForDelegate. 
Docs: http://msdn.microsoft.com/en-us/lib...es.marshal.getfunctionpointerfordelegate.aspx

If would like to clarify one thing for people searching this problem in future: generally, 
when you call something on C/C++ side from C#, anything you pass will exist (is valid) only during the call, 
which would be pretty problematic for delegates. However delegates are an exception: 
function pointer passed to C/C++ from C# is valid as long as original C# delegate object exists. 
That means we should create a delegate variable for the C/C++ callback and keep it alive while C/C++ can invoke it! 
(Of course it's not necessary if the callback can be invoked only during the C/C++ call.) 
Source: http://www.mono-project.com/docs/advanced/pinvoke/#memory-boundaries

++ DLL code (build as DLL, disable /clr [Common Language Runtime])
```
typedef int ( __stdcall *ANSWERCB )( int, int );
static ANSWERCB cb;

extern "C" __declspec( dllexport ) int TakesCallback( ANSWERCB fp, int n, int m )
{
cb = fp;
if( cb )
{
return cb( n, m );
}
return 0;
}
```
Unity C# Script using the DLL
```
using UnityEngine;
using System;
using System.Runtime.InteropServices;

class SomeScript : MonoBehaviour
{
public int whatever = 0;
public delegate int myCallbackDelegate( int n, int m );

[DllImport ("DLLImport_CProj")]
private static extern int TakesCallback( myCallbackDelegate fp, int n, int m );

void Awake()
{	
int resp = TakesCallback( new myCallbackDelegate( this.myCallback ), 10, 20 );
Debug.Log( resp );
}


int myCallback( int n, int m )
{
return n + m + whatever;
}
}
```
## delegate 回调类型
多次性回调或可重入回调需要显式的引用，保持delegate生命周期
```
    // during the course of this call into the plugin, it will call back the _onetime_callback() function.
    // because the plugin call/marshaling layer retains a reference to the SimpleCallback delegate, it
    // can not be freed or GC'd during the call
    // all of the following syntaxes work:
    // 1. reply_during_call(new SimpleCallback(this._onetime_callback));
    // 2. reply_during_call(this._onetime_callback);
    // 3. below, the most clear form
    reply_during_call(_onetime_callback);

    // to pass a delegate that is called after the call into the plugin completes, either later
    // or repeatedly later, you have to retain the delegate, which you can only do by holding
    // it in a wider-scope, in this case in a private member/ivar. the marshaling layer will
    // add a hold/addref/retain to the delegate during the call and release it on return, so
    // unless you are holding on to it the plugin would be left with an invalid pointer as
    // soon as GC runs. it's worth understanding that the delegate is effectively two "objects":
    // a managed object in C# which may move due to GC which is holding onto a fixed
    // (possibly unmanaged - that's runtime-dependent) function-pointer which is what the
    // plugin can refer to. GC may move the managed C# object around, but the function pointer
    // in the native-code plugin remains immobile.
    _recurring_callback_holder = new SimpleCallback(_recurring_callback);
    set_recurring_reply(gameObject.GetHashCode(), _recurring_callback_holder);
```
## .NET 2.0 and SafeHandles
从c#调用c++，要使用SafeHandles封装IntPtr，详细见下文：
http://www.mono-project.com/docs/advanced/pinvoke/#net-20-and-safehandles

In .NET 2.0, a new mechanism for wrapping unmanaged handles was introduced. This new mechanism is exposed by the SafeHandle class. SafeHandles encapsulate a handle in the form of an IntPtr, but by exposing it as a subclass of the SafeHandle class (for example SafeFileHandle or SafeWaitHandle) developers gain type safety.

SafeHandles in addition provide a mechanism to avoid inadvertent handle recycling (for references [1] [2]).

The runtime treats SafeHandles specially and will automatically provide marshalling of these when used in P/Invoke calls. The behavior depends on its use:

On outgoing parameters, the SafeHandle’s handle is passed.
On return values, a new instance of the concrete SafeHandle class is created, and the handle value is set to the returned IntPtr value.
On ref SafeHandles, the outgoing value is ignored (must be zero) and the returned value is turned into a proper SafeHandle.
On structure fields, the SafeHandle’s handle is passed.
For the actual implementation details in Mono, see the SafeHandles document.

# 发送intent
```
    //execute the below lines if being run on a Android device
    #if UNITY_ANDROID
    //Reference of AndroidJavaClass class for intent
    AndroidJavaClass intentClass = new AndroidJavaClass ("android.content.Intent");
    //Reference of AndroidJavaObject class for intent
    AndroidJavaObject intentObject = new AndroidJavaObject ("android.content.Intent");
    //call setAction method of the Intent object created
    intentObject.Call<AndroidJavaObject>("setAction", intentClass.GetStatic<string>("ACTION_SEND"));
    //set the type of sharing that is happening
    intentObject.Call<AndroidJavaObject>("setType", "text/plain");
    //add data to be passed to the other activity i.e., the data to be sent
    intentObject.Call<AndroidJavaObject>("putExtra", intentClass.GetStatic<string>("EXTRA_SUBJECT"), subject);
    intentObject.Call<AndroidJavaObject>("putExtra", intentClass.GetStatic<string>("EXTRA_TEXT"), body);
    //get the current activity
    AndroidJavaClass unity = new AndroidJavaClass ("com.unity3d.player.UnityPlayer");
    AndroidJavaObject currentActivity = unity.GetStatic<AndroidJavaObject>("currentActivity");
    //start the activity by sending the intent data
    currentActivity.Call ("startActivity", intentObject);
    #endif
```
# 获取activity
```
    protected virtual void ConnectToActivity() {
      try {
        using (AndroidJavaClass player = new AndroidJavaClass("com.unity3d.player.UnityPlayer")) {
          androidActivity = player.GetStatic<AndroidJavaObject>("currentActivity");
        }
      } catch (AndroidJavaException e) {
        androidActivity = null;
        Debug.LogError("Exception while connecting to the Activity: " + e);
      }
    }
```
# 调试输出float精度数
```
Vector3 point = new Vector3(0.9887f, 1.56789f, 3.09273475f);
 Debug.Log(point.ToString("F4"));
```

# Extending the UnityPlayerActivity Java Code
When developing a Unity Android application, it is possible to extend the standard UnityPlayerActivity class (the primary Java class for the Unity Player on Android, similar to AppController.mm on Unity iOS) by using plug-ins. An application can override any and all of the basic interaction between the Android OS and the Unity Android application.

Two steps are required to override the default activity:

* Create the new Activity which derives from UnityPlayerActivity;
* Modify the Android Manifest to have the new activity as the application’s entry point.

```
OverrideExample.java:
package com.company.product;
import com.unity3d.player.UnityPlayerActivity;
import android.os.Bundle;
import android.util.Log;

public class OverrideExample extends UnityPlayerActivity {
  protected void onCreate(Bundle savedInstanceState) {
    // call UnityPlayerActivity.onCreate()
    super.onCreate(savedInstanceState);
    // print debug message to logcat
    Log.d("OverrideActivity", "onCreate called!");
  }
  public void onBackPressed()
  {
    // instead of calling UnityPlayerActivity.onBackPressed() we just ignore the back button event
    // super.onBackPressed();
  }
}
```
## java端向unity c#发送消息
```
UnityPlayer.UnitySendMessage("GameObjectName1", "MethodName1", "Message to send");
```
# Building and using plug-ins for Android
[see unity ref](https://docs.unity3d.com/Manual/PluginsForAndroid.html)

There are three ways to make Java JNI calls from your C# scripts:

* raw JNI through the AndroidJNI methods ;
* AndroidJNIHelper class together with AndroidJNI;
* AndroidJavaObject and AndroidJavaClass classes as the most convenient high-level APIs.

```
 AndroidJavaObject jo = new AndroidJavaObject("java.lang.String", "some_string"); 
 // jni.FindClass("java.lang.String"); 
 // jni.GetMethodID(classID, "<init>", "(Ljava/lang/String;)V"); 
 // jni.NewStringUTF("some_string"); 
 // jni.NewObject(classID, methodID, javaString); 
 int hash = jo.Call<int>("hashCode"); 
 // jni.GetMethodID(classID, "hashCode", "()I"); 
 // jni.CallIntMethod(objectID, methodID);
```
## Access java sameples
Because Java plug-ins cannot directly access Objects in your scene, you will need to provide a simple API to your C# code that will allow you to pass a transform to the Java side as well as to tell your Java code when to start rendering.
```
public class GoogleVRVideo : MonoBehaviour {

 private AndroidJavaObject googleAvrPlayer = null;

 private AndroidJavaObject googleVrVideo = null;

 void Awake()

 {

    if (googleAvrPlayer == null)

    {

      googleAvrPlayer = new AndroidJavaObject("com.unity3d.samplevideoplayer.GoogleAVRPlayer");

    }

    AndroidJavaObject googleVrApi = new AndroidJavaClass("com.unity3d.player.GoogleVrApi");

    if (googleVrApi != null) googleVrVideo = googleVrApi.CallStatic<AndroidJavaObject>("getGoogleVrVideo");

 }
  void Start()

 {
   if (googleAvrPlayer != null)

  {

    AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer");

    AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity");

    googleAvrPlayer.Call("initVideoPlayer", jo);

    googleAvrPlayer.Call("play");

  }

  }
 }

```
[see detail](https://docs.unity3d.com/Manual/VRDevices-GoogleVRVideoAsyncReprojection.html)

# capture camera
```
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CaptrueCamera : MonoBehaviour {
    public Camera camera = null;
    public int resWidth = 1;
    public int resHeight = 1;

    private bool takeHiResShot = false;

    public static string ScreenShotName(int width, int height)
    {
        return string.Format("/sdcard/screen_{0}_{1}x{2}_{3}.png",
                             1,//Application.dataPath,
                             width, height,
                             System.DateTime.Now.ToString("yyyy-MM-dd_HH-mm-ss"));
    }

    public void TakeHiResShot()
    {
        takeHiResShot = true;
    }

    void LateUpdate()
    {
        takeHiResShot |= Input.anyKeyDown;
        if (takeHiResShot)
        {
            RenderTexture rt = new RenderTexture(resWidth, resHeight, 24);
            camera.targetTexture = rt;
            Texture2D screenShot = new Texture2D(resWidth, resHeight, TextureFormat.RGB24, false);
            camera.Render();
            RenderTexture.active = rt;
            screenShot.ReadPixels(new Rect(0, 0, resWidth, resHeight), 0, 0);
            camera.targetTexture = null;
            RenderTexture.active = null; // JC: added to avoid errors
            Destroy(rt);
            byte[] bytes = screenShot.EncodeToPNG();
            string filename = ScreenShotName(resWidth, resHeight);
            System.IO.File.WriteAllBytes(filename, bytes);
            Debug.Log(string.Format("Took screenshot to: {0}", filename));
            takeHiResShot = false;
        }
    }
}

```