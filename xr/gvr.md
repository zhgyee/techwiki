# GVR api trace
使用gapid可以trace gvr api流程
# VR HAL
## Low sensor latenc
## Low display latency
SurfaceFlinger single-buffered mode
setSingleBufferMode()
Surface::setAutoRefresh()

commit ccdfd60d79a8b7f1ed6401d0f2e8e29166a10584
Author: Pablo Ceballos <pceballos@google.com>
Date:   Wed Oct 7 15:05:45 2015 -0700

    BQ: Add support for single buffer mode
    
    - Adds a single buffer mode to BufferQueue. In this mode designate the
      first dequeued buffer as the shared buffer. All calls to dequeue()
      and acquire() will then return the shared buffer, allowing the
      producer and consumer to share it.
    - Modify the buffer slot state tracking. Add a new SHARED state for
      the shared buffer in single buffer mode. Also track how many times
      a buffer has been dequeued/queued/acquired as it's possible for a
      shared buffer to be both dequeued and acquired at the same time, or
      dequeued/acquired multiple times. This tracking is needed to know
      when to drop the buffer out of the SHARED state after single buffer
      mode has been disabled.
    - Add plumbing for enabling/disabling single buffer mode from Surface.
    

## Low-persistence display
BRIGHTNESS_MODE_LOW_PERSISTENCE

## Consistent performance of the GPU and CPU
"top-app" cpuset

## Required EGL extensions must be present
* EGL_ANDROID_create_native_client_buffer, 
* EGL_ANDROID_front_buffer_auto_refresh,
* EGL_EXT_protected_content,
* EGL_KHR_mutable_render_buffer,
* EGL_KHR_reusable_sync, and EGL_KHR_wait_sync.

# cpuset
set_cpuset_policy()
	add_tid_to_cgroup()
# API usages
## gvr
```
#ifdef __ANDROID__
// On Android, the gvr_context should almost always be obtained from
// the Java GvrLayout object via
// GvrLayout.getGvrApi().getNativeGvrContext().
gvr_context* gvr = ...;
#else
gvr_context* gvr = gvr_create();
#endif

gvr_initialize_gl(gvr);

gvr_buffer_viewport_list* viewport_list =
    gvr_buffer_viewport_list_create(gvr);
gvr_get_recommended_buffer_viewports(gvr, viewport_list);
gvr_buffer_viewport* left_eye_vp = gvr_buffer_viewport_create(gvr);
gvr_buffer_viewport* right_eye_vp = gvr_buffer_viewport_create(gvr);
gvr_buffer_viewport_list_get_item(viewport_list, 0, left_eye_vp);
gvr_buffer_viewport_list_get_item(viewport_list, 1, right_eye_vp);

while (client_app_should_render) {
  // A client app should be ready for the render target size to change
  // whenever a new QR code is scanned, or a new viewer is paired.
  gvr_sizei render_target_size =
      gvr_get_maximum_effective_render_target_size(gvr);
  // The maximum effective render target size can be very large, most
  // applications need to scale down to compensate.
  render_target_size.width /= 2;
  render_target_size.height /= 2;
  gvr_swap_chain_resize_buffer(swap_chain, 0, render_target_size);

  // This function will depend on your render loop's implementation.
  gvr_clock_time_point next_vsync = AppGetNextVsyncTime();

  const gvr_mat4f head_view =
      gvr_get_head_space_from_start_space_rotation(gvr, next_vsync);
  const gvr_mat4f left_eye_view = MatrixMultiply(
      gvr_get_eye_from_head_matrix(gvr, GVR_LEFT_EYE), head_view);
  const gvr::Mat4f right_eye_view = MatrixMultiply(
      gvr_get_eye_from_head_matrix(gvr, GVR_RIGHT_EYE), head_view);

  // Insert client rendering code here.

  AppSetRenderTarget(offscreen_texture_id);

  AppDoSomeRenderingForEye(
      gvr_buffer_viewport_get_source_uv(left_eye_view),
      left_eye_matrix);
  AppDoSomeRenderingForEye(
      gvr_buffer_viewport_get_source_uv(right_eye_view),
      right_eye_matrix);
  AppSetRenderTarget(primary_display);

  gvr_frame_submit(&frame, viewport_list, head_matrix);
}

// Cleanup memory.
gvr_buffer_viewport_list_destroy(&viewport_list);
gvr_buffer_viewport_destroy(&left_eye_vp);
gvr_buffer_viewport_destroy(&right_eye_vp);

#ifdef __ANDROID__
// On Android, The Java GvrLayout owns the gvr_context.
#else
gvr_destroy(gvr);
#endif

```

Head tracking is enabled by default, and will begin as soon as the
gvr_context is created. The client should call gvr_pause_tracking() and
gvr_resume_tracking() when the app is paused and resumed, respectively.

Note: Unless otherwise noted, the functions in this API may not be
thread-safe with respect to the gvr_context, and it is up the caller to use
the API in a thread-safe manner.

## gvr controller
```

// Get your gvr_context* pointer from GvrLayout:
gvr_context* gvr = ......;  // (get from GvrLayout in Java)

// Set up the API features:
int32_t options = gvr_controller_get_default_options();

// Enable non-default options, if needed:
options |= GVR_CONTROLLER_ENABLE_GYRO | GVR_CONTROLLER_ENABLE_ACCEL;

// Create and init:
gvr_controller_context* context =
    gvr_controller_create_and_init(options, gvr);

// Check if init was successful.
if (!context) {
  // Handle error.
  return;
}

gvr_controller_state* state = gvr_controller_state_create();

// Resume:
gvr_controller_resume(api);
/// Usage:
///
void DrawFrame() {
  gvr_controller_state_update(context, 0, state);
  // ... process controller state ...
}

// When your application gets paused:
void OnPause() {
  gvr_controller_pause(context);
}

// When your application gets resumed:
void OnResume() {
  gvr_controller_resume(context);
}
```
## gvr audio
```
/// Construction:

std::unique_ptr<gvr::AudioApi> gvr_audio_api(new gvr::AudioApi);
gvr_audio_api->Init(GVR_AUDIO_RENDERING_BINAURAL_HIGH_QUALITY);

/// Update head rotation in DrawFrame():

head_pose_ = gvr_api_->GetHeadSpaceFromStartSpaceRotation(target_time);
gvr_audio_api_->SetHeadPose(head_pose_);
gvr_audio_api_->Update();

/// Preload sound file, create sound handle and start playback:

gvr_audio_api->PreloadSoundfile(kSoundFile);
AudioSourceId source_id =
              gvr_audio_api_->CreateSoundObject("sound.wav");
gvr_audio_api->SetSoundObjectPosition(source_id,
                                      position_x,
                                      position_y,
                                      position_z);
gvr_audio_api->PlaySound(source_id, true /* looped playback */);
```