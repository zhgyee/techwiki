# Summery
OpenCL programs are divided in two parts: one that executes on the device (in our case, on the GPU) and other that executes on the host (in our case, the CPU).
* The device program is the one you may be concerned about. It's where the OpenCL magic happens. In order to execute code on the device, programmers can write special functions (called kernels), which are coded with the OpenCL Programming Language - a sort of C with some restrictions and special keywords and data types.
* On the other hand, the host program offers an API so that you can manage your device execution. The host can be programmed in C or C++ and it controls the OpenCL environment (context, command-queue,...).

# Device
![opencl-execution-model](/uploads/c8d12aac5d514dadc83fd0115d3e148c/opencl-execution-model.JPG)

# Host
* Platform: "The host plus a collection of devices managed by the OpenCL framework that allow an application to share resources and execute kernels on devices in the platform." Platforms are represented by a cl_platform object.
* Device: are represented by cl_device objects, initialized with `clGetDeviceIDs` function.
* Context: defines the entire OpenCL environment, including OpenCL kernels, devices, memory management, command-queues, etc. Contexts in OpenCL are referenced by an cl_context object
* Command-Queue: the OpenCL command-queue, as the name may suggest, is an object where OpenCL commands are enqueued to be executed by the device. "The command-queue is created on a specific device in a context [...] Having multiple command-queues allows applications to queue multiple independent commands without requiring synchronization." (OpenCL Specification).

The following examples shows a practical usage of these elements:
```
cl_int error = 0;   // Used to handle error codes
cl_platform_id platform;
cl_context context;
cl_command_queue queue;
cl_device_id device;

// Platform
error = oclGetPlatformID(&platform);
if (error != CL_SUCCESS) {
   cout << "Error getting platform id: " << errorMessage(error) << endl;
   exit(error);
}
// Device
error = clGetDeviceIDs(platform, CL_DEVICE_TYPE_GPU, 1, &device, NULL);
if (err != CL_SUCCESS) {
   cout << "Error getting device ids: " << errorMessage(error) << endl;
   exit(error);
}
// Context
context = clCreateContext(0, 1, &device, NULL, NULL, &error);
if (error != CL_SUCCESS) {
   cout << "Error creating context: " << errorMessage(error) << endl;
   exit(error);
}
// Command-queue
queue = clCreateCommandQueue(context, device, 0, &error);
if (error != CL_SUCCESS) {
   cout << "Error creating command queue: " << errorMessage(error) << endl;
   exit(error);
}
```
[referenced](https://streamcomputing.eu/knowledge/for-developers/tutorials/)

# interact with openGL
```
//init
    EGLDisplay mEglDisplay = eglGetCurrentDisplay();
    EGLContext mEglContext = eglGetCurrentContext();
    cl_context_properties props[] =
    {   CL_GL_CONTEXT_KHR,   (cl_context_properties) mEglContext,
        CL_EGL_DISPLAY_KHR,  (cl_context_properties) mEglDisplay,
        CL_CONTEXT_PLATFORM, 0,
        0 };

// processing
    cl::ImageGL imgIn (theContext, CL_MEM_READ_ONLY,  GL_TEXTURE_2D, 0, texIn);
    cl::ImageGL imgOut(theContext, CL_MEM_WRITE_ONLY, GL_TEXTURE_2D, 0, texOut);
    std::vector < cl::Memory > images;
    images.push_back(imgIn);
    images.push_back(imgOut);
    theQueue.enqueueAcquireGLObjects(&images);
    theQueue.finish();
```
see detail in `opencv-master\samples\android\tutorial-4-opencl\`