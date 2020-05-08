# fill scale
```
    // These may be computed by measuring the distance between the top
    // of the unscaled distorted image and the top of the screen. Denote
    // this distance by Delta. The normalized view coordinate of the
    // distorted image top is
    //     Y = 1 - 2 Delta / Screen_Size_Y
    // We want to scale this coordinate such that it maps to the top of
    // the view. That is,
    //     Y * fill_scale = 1
    // Solving for fill_scale gives the equations below.
    float delta = Centimeter(0.7f);
    app->hmd.left.fill_scale  = 1.0f / (1.0f - 2.0f * delta / Screen_Size_Y);
    app->hmd.right.fill_scale = 1.0f / (1.0f - 2.0f * delta / Screen_Size_Y);
    //using of fill scale
    v[vi].position = vec2(x, y) * config.fill_scale + config.image_centre;
```
if Screen_Size_Y = 0.72m delta = 0.07m then fill_scale = 1.24
![fill scale](img/FillScale.png)
# image centre
```
    // These are computed such that the centers of the displayed framebuffers
    // on the device are seperated by the viewer's IPD.
    app->hmd.left.image_centre    = vec2(+1.0f - Eye_IPD / (Screen_Size_X / 2.0f), 0.0f);
    app->hmd.right.image_centre   = vec2(-1.0f + Eye_IPD / (Screen_Size_X / 2.0f), 0.0f);
    //Eye_IPD / (Screen_Size_X / 2.0f) = (Eye_IPD / 2)/(Screen_Size_X / 4)
```
let Eye_IPD = 64mm Screen_Size_X = 64.8*2mm then 
left.image_centre.x = 0.01234
right.image_centre.x = -0.01234
![image_centre](img/ImageCenter.png)
# distort centre
```
    // These are computed such that the distortion takes place around
    // an offset determined by the difference between lens seperation
    // and the viewer's eye IPD. If the difference is zero, the distortion
    // takes place around the image centre.
    app->hmd.left.distort_centre  = vec2((Lens_IPD - Eye_IPD) / (Screen_Size_X / 2.0f), 0.0f);
    app->hmd.right.distort_centre = vec2((Eye_IPD - Lens_IPD) / (Screen_Size_X / 2.0f), 0.0f);
```

# mashs
## vertices mesh
![vertices positions](img/vertices_mesh.png)
## uv position mesh
![uv positioins](img/uvmash.png)