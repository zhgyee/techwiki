 # TextureView
 TextureView is self-closing view and it is neither a layout nor a container view.
 It is an element / component that doesn't support children.
 ```
<TextureView />
 ```

 # HardwareLayer
 A hardware layer can be used to render graphics operations into a hardware
 friendly buffer. For instance, with an OpenGL backend a hardware layer
 would use a Frame Buffer Object (FBO.) The hardware layer can be used as
 a drawing cache when a complex set of graphics operations needs to be
 drawn several times.
```
	//TextureView create SurfaceTexture, and set HardwareLayer as consumer of This SurfaceTexture
	mLayer = mAttachInfo.mHardwareRenderer.createTextureLayer();
	mSurface = new SurfaceTexture(false);
	mLayer.setSurfaceTexture(mSurface);
	mSurface.setDefaultBufferSize(getWidth(), getHeight());
	nCreateNativeWindow(mSurface);

	mSurface.setOnFrameAvailableListener(mUpdateListener, mAttachInfo.mHandler);
	//when TextureView user draw scene done, notify via onFrameAvaliable, then HWUI get Texture from FBO
	mLayer.prepare(getWidth(), getHeight(), mOpaque);
	mLayer.updateSurfaceTexture();
```

# ViewRootImpl
## draw caller stack
```
android.view.ViewRootImpl.draw(boolean)
android.view.ViewRootImpl.performDraw()
android.view.ViewRootImpl.performTraversals()
android.view.ViewRootImpl.doTraversal()
```
# HardwareRenderer
ThreadedRenderer extends HardwareRenderer
```
//init
mAttachInfo.mHardwareRenderer = HardwareRenderer.create(mContext, translucent);
hwInitialized = mAttachInfo.mHardwareRenderer.initialize(mSurface);
//transvals
hardwareRenderer.setup(mWidth, mHeight, mAttachInfo, mWindowAttributes.surfaceInsets);
//draw
mAttachInfo.mHardwareRenderer.draw(mView, mAttachInfo, this);
//animator
mAttachInfo.mHardwareRenderer.registerAnimatingRenderNode(animator);
//destroy
mAttachInfo.mHardwareRenderer.stopDrawing();
mAttachInfo.mHardwareRenderer.destroyHardwareResources(mView);
mAttachInfo.mHardwareRenderer.destroy();
```
# DisplayListCanvas
```
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        if (canvas.isHardwareAccelerated()) {
            DisplayListCanvas displayListCanvas = (DisplayListCanvas) canvas;
            displayListCanvas.drawCircle(mX, mY, mRadius, mPaint);
        }
    }
```
```
	DisplayListCanvas canvas = mRootNode.start(mSurfaceWidth, mSurfaceHeight);

	final int saveCount = canvas.save();
	canvas.translate(mInsetLeft, mInsetTop);
	callbacks.onHardwarePreDraw(canvas);

	canvas.insertReorderBarrier();
	canvas.drawRenderNode(view.updateDisplayListIfDirty());
	canvas.insertInorderBarrier();

	callbacks.onHardwarePostDraw(canvas);
	canvas.restoreToCount(saveCount);
```