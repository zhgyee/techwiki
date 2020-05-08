#chromium debug
## enable log
```
adb shell setprop persist.sys.br.log true
```
## command line arg
```
build/android/adb_android_webview_command_line
build/android/adb_chrome_public_command_line
```

# chromium build
1. 将src目录下的depot_tools添加到系统路径中
`export PATH=~/chromium/chromium/src/depot_tools:"$PATH"`
并且需要调整java到1.7版本
接下来就是编译工作了,而编译的工具可以使用GYP也可以使用GN 
从Google文档来看,GYP较老较稳定,GN较新并且正在开发。 
从chromium的发展历史来看,假以时日估计还是会都转到GN上。
但是目前我们仍然只能使用GYP来编译androidM所需要的system_webview_apk
2. 先需要配置相关依赖库 
`sudo ./build/install-build-deps-android.py`
如果没有任何错误就可以进行下面步骤,如果出现错误,也可尝试是否能够使用GYP进行编
译
3. 使用GYP编译
首先需要配置下GYP的环境变量
在chromium根目录下执行 
`echo "{ 'GYP_DEFINES': 'OS=android', }" > chromium.gyp_env`
这样最终生成的apk会是arm架构下的
如果你需要编译arm的64位的,则需要define target_arch 
`echo "{ 'GYP_DEFINES': 'OS=android target_arch=arm64', }" >
chromium.gyp_env`
如果是intel x86下的则是 
`echo "{ 'GYP_DEFINES': 'OS=android target_arch=ia32', }" >
chromium.gyp_env`
如果是intel x64下的则是 
`echo "{ 'GYP_DEFINES': 'OS=android target_arch=x64', }" >
chromium.gyp_env`
然后执行 `gclient runhooks`
注:如果之后修改过任何的gyp文件,或者添加了些新文件后都需要重新`glient runhooks`
过一会儿执行完毕之后进到src目录
使用 `ninja -C out/Release system_webview_apk` 
来编译系统的webview.apk
`ninja -C out/Release chrome_public_apk`
当然也可以换成content_shell_apk来编译content shell(就是一个webview多加一个url栏)
4. 使用GN编译
GN编译优势是不需要设置GYPENV,而是根据不同的GN设置创建不同的out输出目录。 
这个在我们需要同时编译arm,arm64,x86,x86_64各个arch的webview.apk的时候,就比GYP
要好的多。 
但是目前发现GN编译并不提供system_webview_apk的编译target 
不知是否为别名还是就是不提供

#chromium source
## top-level code
https://www.chromium.org/developers/how-tos/getting-around-the-chrome-source-code
## android webview source tree
### CHROMIUM TREE 
 `external/chromium_org`
### android tree 
```
frameworks/base/core/java/android/webkit/ 
frameworks/webview 
```
 https://docs.google.com/document/d/1a_cUP1dGIlRQFUSic8bhAOxfclj4Xzw-yRDljVk1wB0/edit?pli=1
#multi-process architecture
https://www.chromium.org/developers/design-documents/multi-process-architecture
* browser  runs the UI and manages tab and plugin processes
 * RenderProcessHost
 * RenderViewHost
 * ResouceDispatcherHost
* renderers, the tab-specific processesuse the WebKit open-source layout engine for interpreting and laying out HTML.
 * RenderProcess
 * RenderView
 * ResourceDispatcher
 * webkit

# life of message 
##  renderer->browser(set cursor)
```
----RenderProcess-----
RenderWidget::SetCursor
RenderView::SetCursor 
 RenderWidget::Send
 RenderThread::Send
  IPC::SyncChannel
====IPC====
  IPC::ChannelProxy
 ResourceMessageFilter->network/I/O thread
 RenderProcessHost::OnMessageReceived
RenderViewHost::OnMessageReceived
RenderWidgetHost::OnMsgSetCursor
----BrowserProcess----
```
# browser->renderer(mouse event)
```
----Browser----
RenderWidgetHostViewWin::OnMouseEvent
 RenderWidgetHost::ForwardInputEvent
  RenderWidgetHost::Send
   RenderProcessHost::Send
    IPC::ChannelProxy
====IPC====
    IPC::Channel
   RenderView::OnMessageReceived
  RenderWidget::OnMessageReceived
 WebWidgetImpl::HandleInputEvent
WebCore::Widget
----Renderer----
```
# mailbox
Mailbox provides a means to share textures between command buffers and manage their lifetimes. The mailbox is a simple string identifier, which can be attached (consumed) to a local texture id for any command buffer, and then accessed through that texture id alias. Each texture id attached in this way holds a reference on the underlying real texture, and once all references are released by deleting the local texture ids, the real texture is also destroyed.
# reference
https://www.chromium.org/developers/design-documents
