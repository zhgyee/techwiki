# surfaceflinger
## vr display
先用原始context建立vr timewarp thread，然后在绘制每layer时，将空context设置为当前context，然后绘制到eye的FBO上，最终通过timewarp显示到主surface
```
bool SurfaceFlinger::doComposeSurfaces(const sp<const DisplayDevice>& hw, const Region& dirty)
{
#ifdef SVR_FORCE_VR_MODE
        if (hw->getDisplayType() == DisplayDevice::DISPLAY_PRIMARY && (mUserVRMode || mAutoVRMode)) {
           if ( !eglMakeCurrent(mEGLDisplay, mEglVRDummySurface, mEglVRDummySurface, mEGLContext) )
                 ALOGW("User VR mode DisplayDevice::makeCurrent failed. %p",eglGetCurrentSurface( EGL_DRAW ));
           hw->setViewportAndProjection();
        } else
#endif

#ifdef SVR_FORCE_VR_MODE
    if (hw->getDisplayType() == DisplayDevice::DISPLAY_PRIMARY && hasGlesComposition && mForceVRModeEnabled ) {
        if (mVrScene->getEyeBuffers() != NULL) {
            mVrScene->configureEyeBuffers(hw->getWidth(), hw->getHeight());
            mVrScene->startDrawingEyeBuffers();
        }
    }
#endif

#ifdef SVR_FORCE_VR_MODE
    if (hw->getDisplayType() == DisplayDevice::DISPLAY_PRIMARY && hasGlesComposition && mForceVRModeEnabled) {
        if (mVrScene->getEyeBuffers() != NULL) {
            mVrScene->finishDrawingEyeBuffers();
            mVrScene->addSyncObject();
        }
        glBindFramebuffer( GL_FRAMEBUFFER, 0 );
   }
#endif
```
# hwc
## hwcomposer set
```
ExynosOverlayDisplay::set
 +ExynosOverlayDisplay::postFrame
 	+ExynosOverlayDisplay::winconfigIoctl
 		+ioctl(this->mDisplayFd, S3CFB_WIN_CONFIG, win_data);

```

## config window
```
ExynosOverlayDisplay::configureHandle(){
    uint32_t offset = ((uint32_t)sourceCrop.top * handle->stride
         + (uint32_t)sourceCrop.left) * bpp / 8;
    cfg.state = cfg.S3C_FB_WIN_STATE_BUFFER;
    cfg.fd = handle->fd;
    cfg.x = x;
    cfg.y = y;
    cfg.w = w;
    cfg.h = h;
    cfg.format = halFormatToS3CFormat(handle->format);
    cfg.offset = offset;
    cfg.stride = handle->stride * bpp / 8;
    cfg.blending = halBlendingToS3CBlending(blending);
    cfg.fence_fd = fence_fd;
    cfg.plane_alpha = 255;
}
```

# display s3cfb
## init & probe
```
int create_decon_display_controller(struct platform_device *pdev) {
    init_kthread_work(&sfb->update_regs_work, s3c_fb_update_regs_handler);
    sfb->timeline = sw_sync_timeline_create("s3c-fb");

    ret = devm_request_irq(dev, dispdrv->decon_driver.fifo_irq_no,
        s3c_fb_irq, 0, "s3c_fb", sfb);
    sfb->fb_ion_client = ion_client_create(ion_exynos, "fimd");
    sfb->vsync_info.thread = kthread_run(s3c_fb_wait_for_vsync_thread,
            sfb, "s3c-fb-vsync");    
}
```
drivers/video/exynos/decon_display/decon_fb.c
## refresh window
- setup fb info & reg info
- queue work to update regs

```
s3c_fb_ioctl
case S3CFB_WIN_CONFIG:
    ret = s3c_fb_set_win_config(sfb, &p.win_data);
        case S3C_FB_WIN_STATE_BUFFER:
        ret = s3c_fb_set_win_buffer(sfb, win, config, regs);
                handle = ion_import_dma_buf(sfb->fb_ion_client, win_config->fd);
                buf = dma_buf_get(win_config->fd);
                buf_size = s3c_fb_map_ion_handle(sfb, &dma_buf_data, handle, buf, win_no);
                win->fbinfo->fix.smem_start = dma_buf_data.dma_addr + win_config->offset;
                regs->dma_buf_data[win_no] = dma_buf_data;
                regs->vidw_buf_start[win_no] = win->fbinfo->fix.smem_start;
                regs->vidw_buf_end[win_no] = regs->vidw_buf_start[win_no] + window_size;
                regs->vidw_buf_size[win_no] = vidw_buf_size(win_config->w, 
                    win->fbinfo->fix.line_length, win->fbinfo->var.bits_per_pixel);
        list_add_tail(&regs->list, &sfb->update_regs_list);
        queue_kthread_work(&sfb->update_regs_worker, &sfb->update_regs_work);

```

- workqueue thread execute

```
static void s3c_fb_update_regs_handler(struct kthread_work *work)
    s3c_fb_update_regs(sfb, data);
        __s3c_fb_update_regs(sfb, regs);
            s3c_fb_change_frame(sfb, regs, i);//update frame
        s3c_fb_wait_for_vsync(sfb, VSYNC_TIMEOUT_MSEC);//wait next vsync
        sw_sync_timeline_inc(sfb->timeline, 1);//release fence

```

- interrupts

```
static irqreturn_t s3c_fb_irq(int irq, void *dev_id)
{
    irq_sts_reg = readl(regs + VIDINTCON1);
    if (irq_sts_reg & VIDINTCON1_INT_FRAME) {
        /* VSYNC interrupt, accept it */
        writel(VIDINTCON1_INT_FRAME, regs + VIDINTCON1);
        sfb->vsync_info.timestamp = timestamp;
        wake_up_interruptible_all(&sfb->vsync_info.wait);
    }
```
- vsync

```
static int s3c_fb_wait_for_vsync_thread(void *data)
{
    struct s3c_fb *sfb = data;

    while (!kthread_should_stop()) {
        ktime_t timestamp = sfb->vsync_info.timestamp;
        int ret = wait_event_interruptible(sfb->vsync_info.wait,
            !ktime_equal(timestamp, sfb->vsync_info.timestamp) &&
            sfb->vsync_info.active);

        if (!ret) {
            sysfs_notify(&sfb->dev->kobj, NULL, "vsync");
        }
    }

    return 0;
}
```

# decon

```
static int decon_probe(struct platform_device *pdev)
{

    /* Get IRQ resource and register IRQ, create thread */
    ret = decon_int_register_irq(pdev, decon);
    if (ret)
        goto fail;
    ret = decon_int_create_vsync_thread(decon);        

    snprintf(device_name, MAX_NAME_SIZE, "decon%d", decon->id);

    /* register framebuffer */
    fbinfo = decon->windows[decon->pdata->default_win]->fbinfo;
    ret = register_framebuffer(fbinfo);
    init_kthread_worker(&decon->update_regs_worker);

    decon->update_regs_thread = kthread_run(kthread_worker_fn,
            &decon->update_regs_worker, device_name);  
    init_kthread_work(&decon->update_regs_work, decon_update_regs_handler);

    decon->timeline = sw_sync_timeline_create(device_name);
    snprintf(device_name, MAX_NAME_SIZE, "decon%d-wb", decon->id);
    decon->wb_timeline = sw_sync_timeline_create(device_name);                    
```
##  decon win config
S3CFB_WIN_CONFIG
```
static int decon_set_win_config(struct decon_device *decon,
                struct decon_win_config_data *win_data) {
        case DECON_WIN_STATE_BUFFER:
            ret = decon_set_win_buffer(decon, win, config, regs); 

        pt = sw_sync_pt_create(decon->timeline, decon->timeline_max);
        fence = sync_fence_create("display", pt);
        sync_fence_install(fence, fd);
        win_data->fence = fd;   

        list_add_tail(&regs->list, &decon->update_regs_list);
        mutex_unlock(&decon->update_regs_list_lock);
        queue_kthread_work(&decon->update_regs_worker,
                        &decon->update_regs_work);         
}

```
## decon thread
```
static void decon_update_regs_handler(struct kthread_work *work)
{
    list_for_each_entry_safe(data, next, &saved_list, list) {
        decon_update_regs(decon, data);
        decon_lpd_unblock(decon);
        list_del(&data->list);
        kfree(data);
    }
}

static void decon_update_regs(struct decon_device *decon, struct decon_reg_data *regs)
{
            decon_fence_wait(regs->dma_buf_data[i][0].fence);
    __decon_update_regs(decon, regs);
    decon_wait_for_vsync(decon, VSYNC_TIMEOUT_MSEC);
    sw_sync_timeline_inc(decon->timeline, 1);
}

```