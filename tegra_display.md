#dc work flow
##  flip page
dc/ext/dev.c

 - setup flip args from ioctl
 - queue flip worker
 - flip workqueue running
```
tegra_dc_ioctl->TEGRA_DC_EXT_FLIP3
	+tegra_dc_ext_flip
		+nvhost_syncpt_create_fence_single_ext()--create release fence
		+queue_work(ext->win[work_index].flip_wq, &data->work);
			|
			V
tegra_dc_ext_flip_worker
	+tegra_dc_update_windows
	+tegra_dc_sync_windows	
```
##  interrupt handle
host/nvhost_intr.c

 - setup interrupt workqueue
 - request irq

```
	for (i = 0; i < dev->info.nb_pts; i++)
		INIT_WORK(&intr->syncpt[i].work, syncpt_thresh_cascade_fn);

	err = request_irq(intr->syncpt_irq,
				syncpt_thresh_cascade_isr,
				IRQF_SHARED, "host_syncpt", dev);
```

 - receive interrupt than queue work
 - workqueue running
```
syncpt_thresh_cascade_isr
	+queue_work(intr->wq, &sp->work);
syncpt_thresh_cascade_fn
	+nvhost_syncpt_thresh_fn
		+process_wait_list
			+run_handlers
				+action_signal_sync_pt

static action_handler action_handlers[NVHOST_INTR_ACTION_COUNT] = {
	action_submit_complete,
	action_gpfifo_submit_complete,
	action_signal_sync_pt,
	action_wakeup,
	action_wakeup_interruptible,
};				
```

