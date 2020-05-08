# 针孔成像原理
![PinHoleModel](/uploads/aa3841d278e9d3d37dc6de184b6a3a7e/PinHoleModel.PNG)
![PerspectiveProjection1](/uploads/49f03cde5da189bd0623fcca4a6b967b/PerspectiveProjection1.PNG)

```p=[x,y,z] => p'=[x',y',z']=[-d*x/z, -d*y/z, -d]```

![PerspectiveProjection2](/uploads/6f77e636ecc3c8a59955ffed687407ca/PerspectiveProjection2.PNG)

```p'=[d*x/z, d*y/z, d]=[x, y, z]/(z/d)```

# 透视矩阵生成过程
![PerspectiveProjection](/uploads/dd680315a2bfecdec75f0acd33525802/PerspectiveProjection.PNG)

* Tp---透视变换，变换后的线性结果为 (nx, ny, (n+f)z-fn, z)，非线性结果为(nx/z, ny/z, n+f-fn/z, 1)。保留z坐标的深度信息，并且让z处于[n,f]范围。n为near plane，虚投影面的位置。
* Tst--归一化，将x从r~l,y从t~b，z从n~f归一为[-1,1]

# Project matrixs
## defined by focal length
```math
\begin{pmatrix}
e & 0   & 0 & 0\\ 
0 & e/a & 0 & 0\\ 
0 & 0   & -\frac{f+n}{f-n} & -\frac{2fn}{f-n} \\
0 & 0 & -1 & 0
\end{pmatrix}
\text{ where e is flocal length } e = \frac{1}{tan(\frac{FOV}{2})} \text{ and a is aspect ratio } a = \frac{h}{w}
```
## defined by viewport
```math
\begin{pmatrix}
\frac{2n}{r-l} & 0   & \frac{r+l}{r-l} & 0\\ 
0 & \frac{2n}{t-b} & \frac{t+b}{t-b} & 0\\ 
0 & 0   & -\frac{f+n}{f-n} & -\frac{2fn}{f-n} \\
0 & 0 & -1 & 0
\end{pmatrix}
```
## Infinite project matrix
```math
\begin{pmatrix}
e & 0   & 0 & 0\\ 
0 & e/a & 0 & 0\\ 
0 & 0   & -1 & -2 \\
0 & 0 & -1 & 0
\end{pmatrix}

```
viewport version
```math
\begin{pmatrix}
\frac{2n}{r-l} & 0   & \frac{r+l}{r-l} & 0\\ 
0 & \frac{2n}{t-b} & \frac{t+b}{t-b} & 0\\ 
0 & 0   & -1 & -2 \\
0 & 0 & -1 & 0
\end{pmatrix}

```
## orthographic matrix
```math
\begin{pmatrix}
\frac{2}{r-l} & 0 & 0  & -\frac{r+l}{r-l}\\ 
0 & \frac{2}{t-b} & 0 &-\frac{t+b}{t-b} \\ 
0 & 0   & -\frac{2}{f-n} & -\frac{f+n}{f-n} \\
0 & 0 & 0 & 1
\end{pmatrix}
```

# The center of projection, Camera position, focal length, FOV

The center of projection represents the location of the viewer's eye or the camera's lens.    
The distance between the center of projection and the image plane affects **how flat or deep** the 2D images appear. It also controls how much of the 3D world appears in the image. If you have a perspective image and know the the distance to the center of projection that was used to create it, **you can calculate information about the 3D objects**.

# Off-center perspective projection
![off-axis-frustum](/uploads/3218af5efd4a52e0c368df66c393c496/off-axis-frustum.gif)

The above diagram (view from above the two cameras) is intended to illustrate how the amount by which to offset the frustums is calculated. Note there is only horizontal parallax. This is intended to be a guide for OpenGL programmers, as such there are some assumptions that relate to OpenGL that may not be appropriate to other APIs. The eye separation is exaggerated in order to make the diagram clearer.

The half width on the projection plane is given by

`widthdiv2 = camera.near * tan(camera.aperture/2)`
This is related to world coordinates by similar triangles, the amount D by which to offset the view frustum horizontally is given by
```
D = 0.5 * camera.eyesep * camera.near / camera.fo
aspectratio = windowwidth / (double)windowheight;         // Divide by 2 for side-by-side stereo
widthdiv2   = camera.near * tan(camera.aperture / 2); // aperture in radians
cameraright = crossproduct(camera.dir,camera.up);         // Each unit vectors
right.x *= camera.eyesep / 2.0;
right.y *= camera.eyesep / 2.0;
right.z *= camera.eyesep / 2.0;
```
## Symmetric - non stereo camera
```
   glMatrixMode(GL_PROJECTION);
   glLoadIdentity();
   glViewport(0,0,windowwidth,windowheight);
   top    =   widthdiv2;
   bottom = - widthdiv2;
   left   = - aspectratio * widthdiv2;
   right  =   aspectratio * widthdiv2;
   glFrustum(left,right,bottom,top,camera.near,camera.far);
   glMatrixMode(GL_MODELVIEW);
   glLoadIdentity();
   gluLookAt(camera.pos.x,camera.pos.y,camera.pos.z,
             camera.pos.x + camera.dir.x,
             camera.pos.y + camera.dir.y,
             camera.pos.z + camera.dir.z,
             camera.up.x,camera.up.y,camera.up.z);
   // Create geometry here in convenient model coordinates
```
## Asymmetric frustum - stereoscopic
```
   // Right eye
   glMatrixMode(GL_PROJECTION);
   glLoadIdentity();
   // For frame sequential, earlier use glDrawBuffer(GL_BACK_RIGHT);
   glViewport(0,0,windowwidth,windowheight);
   // For side by side stereo
   //glViewport(windowwidth/2,0,windowwidth/2,windowheight);
   top    =   widthdiv2;
   bottom = - widthdiv2;
   left   = - aspectratio * widthdiv2 - 0.5 * camera.eyesep * camera.near / camera.fo;
   right  =   aspectratio * widthdiv2 - 0.5 * camera.eyesep * camera.near / camera.fo;
   glFrustum(left,right,bottom,top,camera.near,camera.far);
   glMatrixMode(GL_MODELVIEW);
   glLoadIdentity();
   gluLookAt(camera.pos.x + right.x,camera.pos.y + right.y,camera.pos.z + right.z,
             camera.pos.x + right.x + camera.dir.x,
             camera.pos.y + right.y + camera.dir.y,
             camera.pos.z + right.z + camera.dir.z,
             camera.up.x,camera.up.y,camera.up.z);
   // Create geometry here in convenient model coordinates

   // Left eye
   glMatrixMode(GL_PROJECTION);
   glLoadIdentity();
   // For frame sequential, earlier use glDrawBuffer(GL_BACK_LEFT);
   glViewport(0,0,windowwidth,windowheight);
   // For side by side stereo
   //glVie
```
# ref
[center-of-projection](http://rnhart.net/articles/center-of-projection/)
