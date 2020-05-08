# gear vr 签名
https://dashboard.oculus.com/tools/osig-generator/
osg文件放在unity工程如下路径：
Assets/Plugins/Android/assets

# Utilities assets
* OVRManager: an interface for controlling VR camera behavior with a number of useful features,
* OVRPlayerController: a VR first-person control prefab,
* OVRInput: provides a unified API for Xbox, Touch, and Oculus Remote,
* OVRHaptics: provides an API for Oculus Touch haptic feedback,
* OVRScreenshot: a tool for taking cubemap screenshots of Unity applications,
* Adaptive Resolution: automatically scales down resolution as GPU exceeds 85% utilization, and
* Basic sample scenes.

# Prefabs
Utilities for Unity 5 provides prefabs in Assets/OVR/Prefabs:

## OVRCameraRig
OVRCameraRig contains one Unity camera, the pose of which is controlled by head tracking;     
two “anchor” GameObjects for the left and right eyes;     
and one “tracking space” GameObject that allows you to fine-tune the relationship between the head tracking reference frame and your world.     
The rig is meant to be attached to a moving object, such as a character walking around, a car, a gun turret, et cetera. This replaces the conventional Camera.

The following scripts (components) are attached to the OVRCameraRig prefab:

* OVRCameraRig.cs
* OVRManager.cs

## OVRPlayerController

The OVRPlayerController is the easiest way to start navigating a virtual environment. It is basically an OVRCameraRig prefab attached to a simple character controller. It includes a physics capsule, a movement system, a simple menu system with stereo rendering of text fields, and a cross-hair component.

To use, drag the player controller into an environment and begin moving around using a gamepad, or a keyboard and mouse.

Note: Make sure that collision detection is active in the environment.
One script (Components) is attached to the OVRPlayerController prefab:

* OVRPlayerController.cs 

## OVRCubemapCaptureProbe

# VR Compositor Layers
Overlay显示层，主要用于启动场景或文本菜单显示。