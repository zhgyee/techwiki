# architectrue

# Vulkan objects
![Vulkan-Diagram](/img/Vulkan-Diagram.png)

Solid lines with arrows represent the order of creation. For example, you must specify an existing DescriptorPool to create a DescriptorSet. 
Solid lines with a diamond represent composition, which means that you don’t have to create that object, 
but it already exists inside its parent object and can be fetched from it. For example, you can enumerate PhysicalDevice objects from an Instance object. 
Dashed lines represent other relationships, like submitting various commands to a CommandBuffer.

The diagram is divided into three sections. Each section has a main object, shown in red. 
All other objects in a section are created directly or indirectly from that main object. 
For example, vkCreateSampler – the function that creates a Sampler – takes VkDevice as its first parameter. 
Relationships to main objects are not drawn on this diagram for clarity.

see [ref](https://gpuopen.com/understanding-vulkan-objects/)

# SwapChain
Presentation-->SwapChain--->Surface
                   |------->VkImage
# Graphics Pipeline
Graphics pipeline represents how the renderer itself is configured. It represents the few remaining things that were still fixed-function in graphics pipelines when Vulkan was designed.  
Pipeline stages:  
* pStages*stageCount - Here you provide all the shader modules you want your pipeline to use.
* pVertexInputState - Tells how your vertex data is formatted into attributes.
* pInputAssemblyState - Tells how vertices are used. Mainly what kind of primitives are assembled from them.
* pViewportState - The viewport and scissors for rendering.
* pRasterizationState - Kind of miscellaneous things that did not fit elsewhere.
* pMultisampleState - Control to multisampling.
* pColorBlendState - Whether and how blending functions work.
* layout - pipeline layout for your pipeline
* renderPass - render pass that your pipeline is supposed to be compatible with.

These fields are optional:

* pTessellationState - If you're doing things with tessellation shaders.
* pDepthStencilState - If you have a depth or stencil attachment.
* pDynamicState - If you want to change some things dynamically in the command buffer, rather than have them fixed down in the pipeline.

# RenderPass--The framebuffer env
Render pass represent a rendering layer. You could imagine it's like a canvas that is being drawn except that it consists of many images. It describes how the framebuffer is drawn during rendering.

# Synchronization
* Fences, being used to communicate completion of execution of command buffer submissions to queues back to the application.
* Semaphores, being generally associated with resources or groups of resources and can be used to marshal ownership of shared data. Their status is not visible to the host.
* Events, providing a finer-grained synchronization primitive which can be signaled at command level granularity by both device and host, and can be waited upon by either. Events represent a fine-grained synchronization primitive that can be used to gauge progress through a sequence of commands executed on a queue by Vulkan.
* Barriers, providing execution and memory synchronization between sets of commands.

* Fences are GPU to CPU syncs.
* Semaphores are GPU to GPU syncs, they are used to sync queue submissions (on the same or different queues).
* Events are more general, reset and checked on both CPU and GPU.
* Barriers are used for synchronization inside a command buffer.

# vkQueueWaitIdle 
vkQueueWaitIdle is equivalent to submitting a fence to a queue and waiting with an infinite timeout for that fence to signal.    
To wait on the host for the completion of outstanding queue operations for a given queue using vkQueueWaitIdle 

# Barriers
Memory buffer barriers are there if you use GPU to write something into memory buffer while another one is reading from there.

You also want barriers when the host is accessing memory that was written by the GPU. But there's often no need to add a barrier when the host writes into a memory because every command buffer submission does an implicit host-write barrier.

Barrier has three functions in total:    
* Synchronization, ensuring that previous dependent work has completed before new work starts.
* Reformatting, ensuring that data to be read by a unit is in a format that unit understands.
* Visibility, ensuring that data that might be cached on a particular unit is visible to other units that might want to see it.

vkCmdPipelineBarrier inserts a barrier, and it roughly does the following in some order:
[ref](http://boxbase.org/entries/2016/mar/7/vulkan-api-overview-3/)
* It flushes cache lines that have been written.
* It invalidates cache lines that were flushed into GPU memory.
* It stalls a part of a pipeline until the cache lines are flushed.
* On images it chooses the a new cache layout for the image, to match how the subsequent operations need it.

# Semaphores
submit queue with present presentComplete-semaphores, while window present system,
the presentComplete-semaphores signaled, next round fpAcquireNextImageKHR wait for presentComplete-semaphore will return.
```
VkSemaphoreCreateInfo semaphoreCreateInfo = {};
semaphoreCreateInfo.sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO;
semaphoreCreateInfo.pNext = NULL;

// This semaphore ensures that the image is complete
// before starting to submit again
VK_CHECK_RESULT(vkCreateSemaphore(device, &semaphoreCreateInfo, nullptr, &semaphores.presentComplete));

// This semaphore ensures that all commands submitted
// have been finished before submitting the image to the queue
VK_CHECK_RESULT(vkCreateSemaphore(device, &semaphoreCreateInfo, nullptr, &semaphores.renderComplete));

// The wait semaphore ensures that the image is presented
// before we start submitting command buffers agein
submitInfo.waitSemaphoreCount = 1;
submitInfo.pWaitSemaphores = &semaphores.presentComplete;


// The signal semaphore is used during queue presentation
// to ensure that the image is not rendered before all
// commands have been submitted
submitInfo.signalSemaphoreCount = 1;
submitInfo.pSignalSemaphores = &semaphores.renderComplete;

fpAcquireNextImageKHR(device, swapChain, UINT64_MAX, presentComplete, (VkFence)nullptr, currentBuffer);

// Present the current image to the queue
VkPresentInfoKHR presentInfo = {};
presentInfo.sType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR;
presentInfo.pNext = NULL;
presentInfo.swapchainCount = 1;
presentInfo.pSwapchains = &swapChain;
presentInfo.pImageIndices = &currentBuffer;
presentInfo.pWaitSemaphores = &renderComplete;
presentInfo.waitSemaphoreCount = 1;

fpQueuePresentKHR(queue, &presentInfo);
```

# ref
[vulkan api overview](http://boxbase.org/entries/2016/feb/29/vulkan-api-overview-2/)    
[Synchronization for Vulkan: Fences, Semaphores, Events, Barriers](http://www.openvulkan.com/2016/03/24/synchronization-for-vulkan-fences-semaphores-events-barriers/)    
[Vulkan in 30 minutes](https://renderdoc.org/vulkan-in-30-minutes.html#)   
[vulkan tutorial](https://vulkan-tutorial.com/) 