# [Rendering](UnityRendering.md)
# [Script](UnityScript.md)
# [Camera](UnityCamera.md)
# [Graphics](UnityGraphics.md)
# [Lighting](UnityLignting.md)
# [Performance](UnityPerformance.md)
# [Shader](UnityShader.md)
# What is dynamic batching?

Dynamic batching is a form of draw call batching performed by Unity. In short, it combines meshes that share the same material into larger meshes. Doing so reduces the amount of communication between the CPU and the GPU. You can enable or disable it via Edit / Projects Settings / Player, in the Other Settings group.

It only works for small meshes. For example, you'll find that it works with Unity's default cube, but not with the default sphere.
* 材质和mesh都必须相同
