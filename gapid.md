# IDE使用方法
* 使用时要关闭android studio，不然有可能调试连接不上
* 在查看Framebuffer时要选择合适的背景，不然看不到FB渲染的内容

# 主要功能
## gvrapi trace
使用gapid可以调试gvr的接口，很好用的功能
## gles api trace
## vulkan api trace

# api install
所有api都是在spy中实现，如gles，通过export接口，libgapii.so中可以
```
gapid/gapii/cc/gles_exports.cpp
EXPORT EGLBoolean STDCALL eglSwapBuffers(EGLDisplay display, void* surface) {
    Spy* s = Spy::get();
    GAPID_DEBUG("eglSwapBuffers(%p, %p)", display, 
    surface);
    auto spy_ctx = s->enter("eglSwapBuffers", GlesAPI);
    auto _result_ = s->eglSwapBuffers(spy_ctx, display, surface);
    s->exit();
    GAPID_DEBUG("eglSwapBuffers() -- done");
    return _result_;
}
```
spy实现gles/gvr等接口
```
class Spy : public GlesSpy, public GvrSpy, public VulkanSpy {}
```
# interceptor
Install中加载libinterceptor.so
```
Installer::Installer(const char* libInterceptorPath) {
    GAPID_INFO("Installing GAPII hooks...")
    auto lib = dlopen(libInterceptorPath, RTLD_NOW);

```

## exported apis
```
InitializeInterceptor
TerminateInterceptor
FindFunctionByName
InterceptFunction
InterceptSymbol
```

# gapii 

## 可以在代码中加载libgapii.so
```
// Run the installer automatically when the library is loaded.
//
// This is done so the only modification needed to a Java app is a call to
// load library in the main activity:
//
//   static {
//     System.loadLibrary("libgapii.so");
//   }
//
// As this means that the code runs before main, care needs to be taken to
// avoid using any other load time initialized globals, since they may not
// have been initialized yet.
```
## 或者在JDWP调试器中加载libgapii.so
```
// loadAndConnectViaJDWP connects to the application waiting for a JDWP
// connection with the specified process id, sends a number of JDWP commands to
// load the list of libraries.
func (p *Process) loadAndConnectViaJDWP(		
	// Load the library.
	log.D(ctx, "Loading GAPII library...")
	// Work around for loading libraries in the N previews. See b/29441142.
	j.Class("java.lang.Runtime").Call("getRuntime").Call("doLoad", gapiiPath, nil)
	log.D(ctx, "Library loaded")	

```

# go脚本
## do
执行cmd/do路径下的脚本，如build或config等
```
export GOPATH="$DO_DIR/third_party:`( cd \"$DO_DIR/../../../../\" && pwd )`"
cd ${DO_DIR} && go run ./cmd/do/*.go "$@"
```
## 从模板生成代码
cmd/apic/main.go
```
package main

import "github.com/google/gapid/core/app"

const maxErrors = 10

func main() {
	app.ShortHelp = "Apic is a tool for managing api source files."
	app.Run(app.VerbMain)
}
```
