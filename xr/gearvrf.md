# architechture
```
GVRActivity   GLSurfaceView  GVRViewManager---->GLRenderer
      |                          ^
     V                          |
OVRActivity------------------->OvrViewManager
      \------------------------------------/
        \-------------ovrapi--------------/
```
# drawEyes
## vsync触发surfaceview刷新->OvrViewManager.onDrawFrame
```
//E:\src\gearvrf\GearVRf-master\GVRf\Framework\framework\src\main\java\org\gearvrf\GVRViewManager.java
    protected void onDrawFrame() {
        beforeDrawEyes();//tracer & stats etc.
        drawEyes(mActivity.getActivityNative().getNative());
        afterDrawEyes();
    }
```
## 进入native，调用native activity
```
E:\src\gearvrf\GearVRf-master\GVRf\Framework\backend_oculus\src\main\jni\ovr_activity_jni.cpp
JNIEXPORT void JNICALL Java_org_gearvrf_OvrViewManager_drawEyes(JNIEnv * jni, jclass clazz,
        jlong appPtr) {
    GVRActivity *activity = reinterpret_cast<GVRActivity*>(appPtr);
    activity->onDrawFrame();
}
```
## 准备绘制左右眼

```
E:\src\gearvrf\GearVRf-master\GVRf\Framework\backend_oculus\src\main\jni\ovr_activity.cpp
void GVRActivity::onDrawFrame() {
    ovrFrameParms parms = vrapi_DefaultFrameParms(&oculusJavaGlThread_, VRAPI_FRAME_INIT_DEFAULT, vrapi_GetTimeInSeconds(),
            NULL);
    parms.FrameIndex = ++frameIndex;
    parms.MinimumVsyncs = 1;
    parms.PerformanceParms = oculusPerformanceParms_;
    parms.Layers[].Flags |= VRAVRAPI_FRAME_LAYER_TYPE_WORLDPI_FRAME_LAYER_FLAG_CHROMATIC_ABERRATION_CORRECTION;

    const double predictedDisplayTime = vrapi_GetPredictedDisplayTime(oculusMobile_, frameIndex);
    const ovrTracking baseTracking = vrapi_GetPredictedTracking(oculusMobile_, predictedDisplayTime);

    const ovrHeadModelParms headModelParms = vrapi_DefaultHeadModelParms();
    const ovrTracking tracking = vrapi_ApplyHeadModel(&headModelParms, &baseTracking);

    ovrTracking updatedTracking = vrapi_GetPredictedTracking(oculusMobile_, tracking.HeadPose.TimeInSeconds);
    updatedTracking.HeadPose.Pose.Position = tracking.HeadPose.Pose.Position;

    for ( int eye = 0; eye < VRAPI_FRAME_LAYER_EYE_MAX; eye++ )
    {
        ovrFrameLayerTexture& eyeTexture = parms.Layers[VRAPI_FRAME_LAYER_TYPE_WORLD].Textures[eye];

        eyeTexture.ColorTextureSwapChain = frameBuffer_[use_multiview ? 0 : eye].mColorTextureSwapChain;
        eyeTexture.DepthTextureSwapChain = frameBuffer_[use_multiview ? 0 : eye].mDepthTextureSwapChain;
        eyeTexture.TextureSwapChainIndex = frameBuffer_[use_multiview ? 0 : eye].mTextureSwapChainIndex;
        eyeTexture.TexCoordsFromTanAngles = texCoordsTanAnglesMatrix_;
        eyeTexture.HeadPose = updatedTracking.HeadPose;
    }

    if (docked_) {
        const ovrQuatf& orientation = updatedTracking.HeadPose.Pose.Orientation;
        const glm::quat tmp(orientation.w, orientation.x, orientation.y, orientation.z);
        const glm::quat quat = glm::conjugate(glm::inverse(tmp));
        cameraRig_->setRotation(quat);
    } else if (nullptr != cameraRig_) {
        cameraRig_->updateRotation();
    } else {
        cameraRig_->setRotation(glm::quat());
    }

    if (!sensoredSceneUpdated_ && docked_) {
        sensoredSceneUpdated_ = updateSensoredScene();
    }

    // Render the eye images.
    for (int eye = 0; eye < (use_multiview ? 1 :VRAPI_FRAME_LAYER_EYE_MAX); eye++) {

        beginRenderingEye(eye);

        oculusJavaGlThread_.Env->CallVoidMethod(viewManager_, onDrawEyeMethodId, eye);

        endRenderingEye(eye);
    }

    FrameBufferObject::unbind();
    vrapi_SubmitFrame(oculusMobile_, &parms);
}
```
## 渲染左右眼场景
```
E:\src\gearvrf\GearVRf-master\GVRf\Framework\backend_oculus\src\main\java\org\gearvrf\OvrViewManager.java
    void onDrawEye(int eye) {
                GVRCamera rightCamera = mainCameraRig.getRightCamera();
                renderCamera(mMainScene, rightCamera, mRenderBundle);
                // if mScreenshotCenterCallback is not null, capture center eye
                if (mScreenshotCenterCallback != null) {
                    GVRPerspectiveCamera centerCamera = mainCameraRig.getCenterCamera();

                    renderCamera(mMainScene, centerCamera, mRenderBundle);

                    readRenderResult();
                    returnScreenshotToCaller(mScreenshotCenterCallback, mReadbackBufferWidth, mReadbackBufferHeight);

                    mScreenshotCenterCallback = null;
                }
                GVRCamera leftCamera = mainCameraRig.getLeftCamera();
                renderCamera(mMainScene, leftCamera, mRenderBundle);
}
```

# renderCamera
## GVRViewManager
```
E:\src\gearvrf\GearVRf-master\GVRf\Framework\framework\src\main\jni\view_manager_jni.cpp
    void Java_org_gearvrf_GVRViewManager_renderCamera() {
        gRenderer->renderCamera(scene, camera, shader_manager,
                                post_effect_shader_manager, post_effect_render_texture_a,
                                post_effect_render_texture_b);
}
```
## GLRenderer
```
E:\src\gearvrf\GearVRf-master\GVRf\Framework\framework\src\main\jni\engine\renderer\gl_renderer.cpp
void GLRenderer::renderCamera() {
//create render state
        renderRenderDataVector(rstate);
}
```
## renderer
```
E:\src\gearvrf\GearVRf-master\GVRf\Framework\framework\src\main\jni\engine\renderer\renderer.cpp
void Renderer::renderRenderDataVector(RenderState &rstate) {

    if (!do_batching || gRenderer->isVulkanInstace() ) {
        for (auto it = render_data_vector.begin();
                it != render_data_vector.end(); ++it) {
            GL(renderRenderData(rstate, *it));
        }
    } else {
         batch_manager->renderBatches(rstate);
    }
}
```
```
void Renderer::renderRenderData(RenderState& rstate, RenderData* render_data) {
    if (!(rstate.render_mask & render_data->render_mask()))
        return;

    // Set the states
    setRenderStates(render_data, rstate);
    if (render_data->mesh() != 0) {
        GL(renderMesh(rstate, render_data));
    }
    // Restoring to Default.
    // TODO: There's a lot of redundant state changes. If on every render face culling is being set there's no need to
    // restore defaults. Possibly later we could add a OpenGL state wrapper to avoid redundant api calls.
    restoreRenderStates(render_data);
}
```