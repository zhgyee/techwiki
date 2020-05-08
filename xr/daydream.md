# Daydream ready
* Device implementations MUST have at least 2 physical cores.
* Device implementations MUST declare android.software.vr.mode feature.
* Device implementations MUST provide an exclusive core to the foreground application and MUST support the Process.getExclusiveCores API to return the numbers of the cpu cores that are exclusive to the top foreground application. This core MUST not allow any other userspace processes to run on it (except device drivers used by the application), but MAY allow some kernel processes to run as necessary.
* Device implementations MUST support sustained performance mode.
* Device implementations MUST support OpenGL ES 3.2.
* Device implementations MUST support Vulkan Hardware Level 0 and SHOULD support Vulkan Hardware Level 1.
* Device implementations MUST implement EGL_KHR_mutable_render_buffer and EGL_ANDROID_front_buffer_auto_refresh, EGL_ANDROID_create_native_client_buffer, EGL_KHR_fence_sync and EGL_KHR_wait_sync so that they may be used for Shared Buffer Mode, and expose the extensions in the list of available EGL extensions.
* The GPU and display MUST be able to synchronize access to the shared front buffer such that alternating-eye rendering of VR content at 60fps with two render contexts will be displayed with no visible tearing artifacts.
* Device implementations MUST implement EGL_IMG_context_priority, and expose the extension in the list of available EGL extensions.
* Device implementations MUST implement GL_EXT_multisampled_render_to_texture, GL_OVR_multiview, GL_OVR_multiview2 and GL_OVR_multiview_multisampled_render_to_texture, and expose the extensions in the list of available GL extensions.
* Device implementations MUST implement EGL_EXT_protected_content and GL_EXT_protected_textures so that it may be used for Secure Texture Video Playback, and expose the extensions in the list of available EGL and GL extensions.
* Device implementations MUST support H.264 decoding at least 3840x2160@30fps-40Mbps (equivalent to 4 instances of 1920x1080@30fps-10Mbps or 2 instances of 1920x1080@60fps-20Mbps).
* Device implementations MUST support HEVC and VP9, MUST be capable to decode at least 1920x1080@30fps-10Mbps and SHOULD be capable to decode 3840x2160@30fps-20Mbps (equivalent to 4 instances of 1920x1080@30fps-5Mbps).
* The device implementations are STRONGLY RECOMMENDED to support android.hardware.sensor.hifi_sensors feature and MUST meet the gyroscope, accelerometer, and magnetometer related requirements for android.hardware.hifi_sensors.
* Device implementations MUST support HardwarePropertiesManager.getDeviceTemperatures API and return accurate values for skin temperature.
* The device implementation MUST have an embedded screen, and its resolution MUST be at least be FullHD(1080p) and STRONGLY RECOMMENDED TO BE be QuadHD (1440p) or higher.
* The display MUST measure between 4.7" and 6" diagonal.
* The display MUST update at least 60 Hz while in VR Mode.
* The display latency on Gray-to-Gray, White-to-Black, and Black-to-White switching time MUST be ≤ 3 ms.
* The display MUST support a low-persistence mode with ≤5 ms persistence,persistence being defined as the amount of time for which a pixel is emitting light.
* Device implementations MUST support Bluetooth 4.2 and Bluetooth LE Data Length Extension section 7.4.3 .
[ref](http://source.android.com/compatibility/android-cdd.html#7_9_virtual_reality)