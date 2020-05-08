# ARM解决方案
参考《Virtual Reality:Hundreds of Millions of Pixels in Front of Your Eyes》

ARM目前没有成熟的解决方案，只是通过multi-view间接支持，具体支持方法如下：
* 每只眼定义两个高低分辨率的view，通过不同的FOV来控制视野的不同，如两个view分别为512x512，FOV分别为68和90，FOV的计算方法可以参考上述文档
* 使用stencil buffer控制低分辨率veiw的中心区域不渲染，进一步节省像素
* 在shader中合成时，根据距离进行插值，离中心点近的选高分辨率视图

# 高通实现方案
## Bin Based Foveated Rendering
QCOM_framebuffer_foveated
```
    (1) Initialize a foveated framebuffer

        // Allocate and initialize a regular framebuffer and attachments
        GLuint fbo = createFramebufferAndAttachments();
        GLuint providedFeatures;
        glFramebufferFoveationConfigQCOM(fbo,1,1, GL_FOVEATION_ENABLE_BIT_QCOM, &providedFeatures);
        if(!(providedFeatures & GL_FOVEATION_ENABLE_BIT_QCOM)) {
            // Failed to enable foveation
        }

    (2) Setup static foveated rendering

        // Insert code from #1
        GLfloat focalX=0.f, focalY=0.f;  // Setup focal point at the center of screen
        GLfloat gainX=4.f, gainY=4.f;  // Increase these for stronger foveation
        glFramebufferFoveationParametersQCOM(fbo, 0, 0, focalX, focalY, gainX, gainY, 0.f);

    (3) Change eye position for eye tracked foveated rendering

        // Code called whenever the eye position changes
        // It is best to position this call both before rendering anything to
        //   an fbo and right before Flush or changing FBO since some
        //   some implementations can apply this state late by patching command
        //   buffers.
        glFramebufferFoveationParametersQCOM(fbo, 0, 0, focalX, focalY, gainX, gainY, 0.f);

    (4) Setting parameters for a multiview stereo framebuffer

        //focalPointsPerLayer should be 1
        float focalX1=0.f,focalY1=0.f;  // Gaze of left eye
        float focalX2=0.f,focalY2=0.f;  // Gaze of right eye
        float gain_x=10.f,gain_y=10.f;  // Strong foveation
        glFramebufferFoveationParametersQCOM(fbo, 0, 0, focalX1, focalY1,gainX, gainY, 0.f);
        glFramebufferFoveationParametersQCOM(fbo, 1, 0, focalX2, focalY2,gainX, gainY, 0.f);

    (5) Setting parameters for a double wide stereo framebuffer

        //focalPointsPerLayer should be 2
        float focalX1=0.f,focalY1=0.f;  // Gaze of left eye
        float focalX2=0.f,focalY2=0.f;  // Gaze of right eye
        float gainX=10.f,gainY=10.f;
        glFramebufferFoveationParametersQCOM(fbo, 0, 0, focalX1*0.5f-0.5f, focalY1, gainX*2.f ,gainY, 0.f);
        glFramebufferFoveationParametersQCOM(fbo, 0, 1, focalX2*0.5f+0.5f, focalY2, gainX*2.f ,gainY, 0.f);
```
![BinBasedFoveatedRendering](/img/BinBasedFoveatedRendering.PNG)

https://www.khronos.org/registry/OpenGL/extensions/QCOM/QCOM_framebuffer_foveated.txt

# Nvidia解决方案
## Multi Resolution Rendering 多分辨率渲染