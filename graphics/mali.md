# mali arch
```
glapi eglapi
------------ddk user--------------
|
V
cfame
|
V
cmar---->command queue(thread)<------cmarp_event
| 										^
V 										|
base 									|
|atoms									^	
V										|
------------ddk kernel-------------------
kbase 								kbase_work
|										^
V										|
gpu------------------------------------IRQ

```
# mali ddk seq
```
gl draw thread call apis-------------------------->
ddk mali-render thread submit work---------------->
gl_executor create atoms-------------------------->
ddk base layer ioct write atoms to gpu driver----->
------------------kernel---------------------------
kbase layer dispatch atoms to GPU----------------->
    kbase_jd_submit katom------------------------->
                 GPU execute=======================
           IRQ<------------------------------------
        kbase_jd_done<-----------------------------
    kbase_jd_done_work<----------------------------
cmarp_event_handler: WORK_COMPLETED<---------------

```
# mali render thread
##  flush
Flush command queue while swapbuffer or Sync with fence

All work placed in a queue is held in the queue until the queue is flushed.  When the queue is flushed, all work
placed on the queue prior to the flush will be passed on to the underlying device(s) for execution, subject to
dependency resolution.

```
eglCreateSyncKHR
	-->eglp_create_sync
		-->eglp_import_fence
			-->eglp_sync_enqueue_wait
eglSwapBuffers						|
	-->cmar_flush<-------------------
		-->cmarp_signal_send( command_queue->cctx, CMARP_SIGNAL_FLUSH, &data );
			-->Renderthread process sig:CMARP_SIGNAL_FLUSH
```

##  work completed
When the device has finished executing, it calls a callback function (cmar_complete) indicating the work which has
been completed and a return code.  The Marshal will update all corresponding events as necessary, trigger any
callbacks for events which are now complete, and pass further work down to devices if it is now ready to execute.

```
eglClientWaitSyncKHR
	-->eglp_wait_cmar_event
		osu_sem_wait( &(event->complete_signal), timeout_nsec );
CMARP_SIGNAL_WORK_COMPLETED		
```

# mali command queue
```
cmar_create_command_queue<-----eglCreateContext

```

# cmar--Common Marshal
The Marshal manages abstract items of work.  Work consists of @e commands which are placed on @e queues.  Each command
is associated with a specific @e device which will execute it.  Each command can optionally have an associated @e
event.  Events can be used to track completion of commands, and support registration of callback functions which will
be called when the associated command completes.  Events can also be used to describe dependencies between commands;
when a command is added to a queue a list of predecessor events can be specified.

All work placed in a queue is held in the queue until the queue is flushed.  When the queue is flushed, all work
placed on the queue prior to the flush will be passed on to the underlying device(s) for execution, subject to
dependency resolution.  Dependencies between commands destined from the same device can be delegated to the device
itself for handling, provided the device has that capability. 

Devices are registered in advance with the Marshal prior to commands being enqueued.  When a device is registered, the
user provides a bitmask describing the device's capabilities, an @e executor function to be called when work is ready
for execution on the device, and some user data to be passed to the executor to identify the device (this allows
multiple devices to share the same executor function).

When work is ready for execution, the executor function is called with a list of one or more commands which are
runnable.  The executor function is expected to return immediately with a status code indicating whether the work was
accepted or not.  If the work is not accepted, the Marshal will call the executor again after a callback indicating
that the device is ready for more work is received.

When the device has finished executing, it calls a callback function (cmar_complete) indicating the work which has
been completed and a return code.  The Marshal will update all corresponding events as necessary, trigger any
callbacks for events which are now complete, and pass further work down to devices if it is now ready to execute.

All devices, queues and events (and by extension commands) are associated with a context, which manages memory
allocation of these objects and includes a <em>render thread</em> which handles dependency resolution and passes work
on to devices for execution.

## cmar_usage_initialization Initialization: Context, Device and Queue allocation.

```
cctx_context *cctx;
cmar_device *cmar_dev;
cmar_command_queue *cmar_queue;

cctx = cmar_get_default();
cmar_dev = cmar_create_device( cctx, my_executor, CMAR_DEVICE_DEPENDENCIES, devicedata );
cmar_queue = cmar_create_command_queue( cctx, 0, contextdata );
```

## cmar_usage_frontend Enqueuing work (front end)
The front end Marshal interface accepts commands into queues and allows queues to be flushed.
```
cmar_command *a_cmd;
cmar_event *an_event;

a_cmd = my_allocator( sizeof( cmar_command ));
if (NULL == cmar_init_command( a_cmd ))
{
    //do some error management
}
// Optionally set dependencies via cmar_set_dependencies.

// The device parameter determines which executor will be called to execute the work
cmar_enqueue_command( cmar_queue, a_cmd, cmar_dev, the_payload, &an_event );

cmar_flush( cmar_queue );

```

## cmar_usage_backend Executing work (back end)
When work is ready for execution, the executor function is called by cmar.
```
cmar_device_status my_executor( cmar_device *device, cmar_command *command )
{
	if( busy )
	{
		return CMAR_DEVICE_STATUS_BUSY; // Busy, work will be requeued later.
	}

	// Prepare the work and submit it to the device.
	// command->cmarp.payload contains work to be performed, as passed into cmar_enqueue_command().

	return CMAR_DEVICE_STATUS_READY; // Ready for more work.
}
```

## Once the work has completed (asynchronously), the complete function should be called.
```
cmar_complete( exe_params, CMAR_EVENT_COMPLETE );
```

kbase_jd_done - Complete a job that has been removed from the Hardware
This must be used whenever a job has been removed from the Hardware, e.g.:
An IRQ indicates that the job finished (for both error and 'done' codes), or
the job was evicted from the JS_HEAD_NEXT registers during a Soft/Hard stop.