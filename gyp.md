#gyp概述
GYP is interesting. It was initially developed by the Chromnium developers at Google to solve exactly the problem of keeping multiple build definitions in sync. GYP has spread to other projects, such as V8 and is used by Node for building native addons. GYP is still rough around the edges, but very usable.

The input to gyp are *.gyp files which are JSON. (Actually a python dialect, that allows comments and trailing comments.) The structure is quite simple:
```
{
  'variables': {
    # ...
  },
  'includes': [
    '../build/common.gypi'
  ],
  'target_defaults': {
    # ...
  },
  'targets': [
    {
      'target_name': 'moo',
        # ...
    },
    {
      'target_name': 'foo',
        # ...
    }
  ]
}
```
## 编译webrtc动态链接库
* webrtc gyp文件，libwebrtc.gyp
```
{
  'includes': ['../webrtc/build/common.gypi'],
  'conditions': [
    ['os_posix == 1 and OS != "mac" and OS != "ios"', {
     'conditions': [
       ['sysroot!=""', {
         'variables': {
           'pkg-config': '../../../build/linux/pkg-config-wrapper "<(sysroot)" "<(target_arch)"',
         },
       }, {
         'variables': {
           'pkg-config': 'pkg-config'
         },
       }],
     ],
    }],
    ['OS=="linux" or OS=="android"', {
      'targets': [
        {
          'target_name': 'libwebrtc',
          'type': 'shared_library',
          'dependencies': [
            '<(webrtc_root)/base/base.gyp:rtc_base',
            '<(webrtc_root)/common.gyp:webrtc_common',
            '<(webrtc_root)/webrtc.gyp:webrtc',
            '<(webrtc_root)/voice_engine/voice_engine.gyp:voice_engine',
            '<(webrtc_root)/sound/sound.gyp:rtc_sound',
            '<(webrtc_root)/system_wrappers/system_wrappers.gyp:*',
            '<(webrtc_root)/modules/modules.gyp:video_capture_module_internal_impl',
            '<(webrtc_root)/modules/modules.gyp:video_render_module_internal_impl',
            '<(webrtc_root)/modules/modules.gyp:video_render_module',
          ],
          'sources': [
            'webrtc_video_engine.cc',
          ],          
          'include_dirs': [
            '<(webrtc_root)',
          ],
          'cflags_cc': [
              '-fvisibility=default',
            ],
          
          }],
      }],
    ],
}    

```
注意webrtc中默认将符号都置为hidden，对外链接不可见，所以在新增代码中加入'-fvisibility=default'供外部调用。
* 在webrtc中增加编译依赖
```
diff --git a/all.gyp b/all.gyp
index 40dbc13..3ce9ad7 100644
--- a/all.gyp
+++ b/all.gyp
@@ -18,6 +18,7 @@
       'type': 'none',
       'dependencies': [
         'webrtc/webrtc.gyp:*',
+        'libwebrtc/libwebrtc.gyp:*',
         'talk/libjingle.gyp:*',
         '<@(webrtc_root_additional_dependencies)',
       ],

```
* 运行`gclient runhooks`生成ninja文件，再执行ninja -C out/Debug libwebrtc进行编译