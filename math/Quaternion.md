# 四元数运算
 * 四元数乘法：q1q2=(v1×v2+w1v2+w2v1,w1w2−v1⋅v2)
 * 共轭四元数：q=(−v ,w)
 * 四元数的模：N(q) = sqrt(x^2 + y^2 + z^2 +w^2)，即四元数到原点的距离
 * 四元数的逆：inv(q)=q∗N(q)    
 * The quaternion inverse gives a rotation around the same axis but of opposite angle
 * 四元数旋转:

  我们可以使用一个四元数q=((x,y,z)sinθ2, cosθ2) 来执行一个旋转。具体来说，如果我们想要把空间的一个点P绕着单位向量轴u = (x, y, z)表示的旋转轴旋转θ角度，
  我们首先把点P扩展到四元数空间，即四元数p = (P, 0)。那么，旋转后新的点对应的四元数（当然这个计算而得的四元数的实部为0，虚部系数就是新的坐标）为：
p′=qp*inv(q)
其中，q=(cosθ2, (x,y,z)sinθ2) ，inv(q)=(q∗)/N(q)，由于u是单位向量

  我们举个最简单的例子：把点P(1, 0, 1)绕旋转轴u = (0, 1, 0)旋转90°，求旋转后的顶点坐标。首先将P扩充到四元数，即p = (P, 0)。而q = (u*sin45°, cos45°)。求p′=qpq−1的值。建议大家一定要在纸上计算一边，这样才能加深印象，连笔都懒得动的人还是不要往下看了。最后的结果p` = ((1, 0, -1), 0)，即旋转后的顶点位置是(1, 0, -1)。

[ref](http://blog.csdn.net/candycat1992/article/details/41254799)

# rotation quaternion & vector quaternion
In general, there are two types of quaternions important for our application: quaternions representing a rotation and
vector quaternions.

A valid rotation quaternion has unit length and the quaterions q and −q represent the same rotation.

A vector quaternion representing a 3D point or vector u = (ux, uy, uz) can have an arbitrary length but its scalar
part is always zero


# 轴角到四元数
给定一个单位长度的旋转轴(x, y, z)和一个角度θ。对应的四元数为：
`q=((x,y,z)sin(θ/2), cos(θ/2)) `
```
quat quat::fromaxisangle(float angle, vec3 axis)
{
    float half_sin = sin(0.5f * angle);
    float half_cos = cos(0.5f * angle);
    return quat(half_cos,
                half_sin * axis.x,
                half_sin * axis.y,
                half_sin * axis.z);
}
```
# 四元数到轴角
```
a= (a,b,c,d)
unit quaternions   => a^2+b^2+c^2+d^2=1
q=(cos(θ/2), v1sin(θ/2), v2sin(θ/2), v3sin(θ/2)
θ=2acos(a) v=1/(sqrt(1-a^2))(b, c, d)
```
![quat-axe](/uploads/4aafb871edc3bf676ebdcb19699c9af5/quat-axe.PNG)

轴角和欧拉角对应关系：pitch-x yaw-y roll-z

## right-hand to left-hand
```
It is a (right or left depending on the order of transformations) multiplication by the quaternion (0, 1, 0, 0).

(0, 1, 0, 0) * (w, x, y, z) = (-x, w, -z, y)

(w, x, y, z) * (0, 1, 0, 0) = (-x, w, z, -y)

Given:    Right Hand: {w,x,y,z}
Option 1: Left Hand: {y,-z,-w,-x}
Option 2: Left Hand: {-y,z,w,x} (equivalent)
```
unity使用左手坐标系，一般底层传感器数据是右手坐标系通常需要转换 转换方法为：

"Rotation" + x + y + -z + -w + "Position" + px + py + -pz 

下面rotate和quat是等价的

```
    Quaternion rotate = centerEyeTransform.transform.rotation;
    Debug.Log("SetCameraRotation:" + rotate[0] + " " + rotate[1] + " " + -rotate[2] + " " + -rotate[3]);

    Pose3D pose3D = new Pose3D(new Vector3(0, 0, 0), rotate);
    
    Quaternion quat = Quaternion.LookRotation(pose3D.RightHandedMatrix.GetColumn(2),
        pose3D.RightHandedMatrix.GetColumn(1));
    Debug.Log("SetCameraRotation2:" + quat[0] + " " + quat[1] + " " + quat[2] + " " + quat[3]);
```

SetCameraRotation:0.01555267 0.06134746 -0.06196381 -0.9960698

SetCameraRotation2:-0.01555267 -0.06134747 0.0619638 0.9960698
# 等价四元数和逆
![quat-equal](/uploads/2a9d67f95c3f008a68c7b562f2cffb6a/quat-equal.PNG)
![quat-relation](/uploads/734aa931715f51d7144473497090ed89/quat-relation.PNG)

# quaternion from two vectors
```
quat quat::fromtwovectors(vec3 u, vec3 v)
{
    float cos_theta = dot(normalize(u), normalize(v));
    float angle = acos(cos_theta);
    vec3 w = normalize(cross(u, v));
    return quat::fromaxisangle(angle, w);
}
```
# Quaternion to Matrix
Quaternion multiplication and orthogonal matrix multiplication can both be used to represent rotation. If a quaternion is represented by qw + i qx + j qy + k qz , then the equivalent matrix, to represent the same rotation, is:
```
1 - 2*qy2 - 2*qz2	2*qx*qy - 2*qz*qw	2*qx*qz + 2*qy*qw
2*qx*qy + 2*qz*qw	1 - 2*qx2 - 2*qz2	2*qy*qz - 2*qx*qw
2*qx*qz - 2*qy*qw	2*qy*qz + 2*qx*qw	1 - 2*qx2 - 2*qy2
```

# Matrix to Quernion
```
    Quaternion quat = Quaternion.LookRotation(pose3D.RightHandedMatrix.GetColumn(2),
        pose3D.RightHandedMatrix.GetColumn(1));
        
```
```
// OpenGL matrix convention for typical GL software
// with positive Y=up and positive Z=rearward direction
RT = right
UP = up
BK = back
POS = position/translation
US = uniform scale
 
float transform[16];
 
[0] [4] [8 ] [12]
[1] [5] [9 ] [13]
[2] [6] [10] [14]
[3] [7] [11] [15]
 
[RT.x] [UP.x] [BK.x] [POS.x]
[RT.y] [UP.y] [BK.y] [POS.y]
[RT.z] [UP.z] [BK.z] [POS.Z]
[    ] [    ] [    ] [US   ]
```
![](http://www.songho.ca/opengl/files/gl_anglestoaxes01.png)

# 欧拉角到四元数：
给定一个欧拉旋转(X, Y, Z)（即分别绕x轴、y轴和z轴旋转X、Y、Z度），则对应的四元数为：
```
x = sin(Y/2)sin(Z/2)cos(X/2)+cos(Y/2)cos(Z/2)sin(X/2)
y = sin(Y/2)cos(Z/2)cos(X/2)+cos(Y/2)sin(Z/2)sin(X/2)
z = cos(Y/2)sin(Z/2)cos(X/2)-sin(Y/2)cos(Z/2)sin(X/2)
w = cos(Y/2)cos(Z/2)cos(X/2)-sin(Y/2)sin(Z/2)sin(X/2)
q = ((x, y, z), w)
```
它的证明过程可以依靠轴角到四元数的公式进行推导。

# ref
* [understanding-quaternions](http://www.3dgep.com/understanding-quaternions/)
* [beautiful-maths-quaternion-from-vectors](http://lolengine.net/blog/2013/09/18/beautiful-maths-quaternion-from-vectors)