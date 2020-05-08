# RenderManager
## RebderManagerBase
```
osvr::renderkit::RenderManager::PresentEye()
	osvr::renderkit::RenderManager::PresentRenderBuffersInternal() : bool
		osvr::renderkit::RenderManager::PresentRenderBuffers() : bool
		osvr::renderkit::RenderManagerOpenGL::RenderFrameFinalize() : bool
			osvr::renderkit::RenderManager::Render(const RenderParams &) : bool
```
## RenderManagerOpenGL
```
osvr::renderkit::RenderManagerOpenGL::PresentEye(PresentEyeParameters) : bool
	osvr::renderkit::RenderManager::PresentRenderBuffersInternal() : bool
		osvr::renderkit::RenderManager::PresentRenderBuffers() : bool
			DoRender() : void
				OnRenderEvent(int) : void
```
## Shader
```
//==========================================================================
// Vertex and fragment shaders to perform our combination of asynchronous
// time warp and distortion correction.

static const GLchar* distortionVertexShader =
"#version 100\n"
"attribute vec4 position;\n"
"attribute vec2 textureCoordinateR;\n"
"attribute vec2 textureCoordinateG;\n"
"attribute vec2 textureCoordinateB;\n"
"uniform mat4 projectionMatrix;\n"
"uniform mat4 modelViewMatrix;\n"
"uniform mat4 textureMatrix;\n"
"varying vec2 warpedCoordinateR;\n"
"varying vec2 warpedCoordinateG;\n"
"varying vec2 warpedCoordinateB;\n"
"void main()\n"
"{\n"
"   gl_Position = projectionMatrix * modelViewMatrix * position;\n"
"   warpedCoordinateR = vec2(textureMatrix * "
"      vec4(textureCoordinateR,0,1));\n"
"   warpedCoordinateG = vec2(textureMatrix * "
"      vec4(textureCoordinateG,0,1));\n"
"   warpedCoordinateB = vec2(textureMatrix * "
"      vec4(textureCoordinateB,0,1));\n"
"}\n";
```
```
static const GLchar* distortionFragmentShader =
"#version 100\n"
"precision highp float;\n"
"uniform sampler2D tex;\n"
"varying vec2 warpedCoordinateR;\n"
"varying vec2 warpedCoordinateG;\n"
"varying vec2 warpedCoordinateB;\n"
"void main()\n"
"{\n"
"    gl_FragColor.r = texture2D(tex, warpedCoordinateR).r;\n"
"    gl_FragColor.g = texture2D(tex, warpedCoordinateG).g;\n"
"    gl_FragColor.b = texture2D(tex, warpedCoordinateB).b;\n"
"}\n";
```
## AsyncTimewarp
osvr::renderkit::RenderManager::ComputeAsynchronousTimeWarps(vector<RenderInfo,allocator<RenderInfo>>, vector<RenderInfo,allocator<RenderInfo>>, float) : bool

### eye tex crop

```
        float textureMat[] = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 };
        if (params.m_timeWarp != nullptr) {
          // Because the matrix was built in compliance with the OpenGL
          // spec, we can just directly use it.
          memcpy(textureMat, params.m_timeWarp->data, 15 * sizeof(float));
        }

        // We now crop to a subregion of the texture.  This is used to handle
        // the
        // case where more than one eye is drawn into the same render texture
        // (for example, as happens in the Unreal game engine).  We base this on
        // the normalized cropping viewport, which will go from 0 to 1 in both
        // X and Y for the full display, but which will be cut in half in in one
        // dimension for the case where two eyes are packed into the same
        // buffer.
        // We scale and translate the texture coordinates by multiplying the
        // texture matrix to map the original range (0..1) to the proper
        // location.
        // We read in, multiply, and write out textureMat.
        matrix16 crop;
        ComputeRenderBufferCropMatrix(params.m_normalizedCroppingViewport,
          crop);
        Eigen::Map<Eigen::MatrixXf> textureEigen(textureMat, 4, 4);
        Eigen::Map<Eigen::MatrixXf> cropEigen(crop.data, 4, 4);
        Eigen::MatrixXf full(4, 4);
        full = textureEigen * cropEigen;
        memcpy(textureMat, full.data(), 16 * sizeof(float));

        glUniformMatrix4fv(m_textureUniformId, 1, GL_FALSE, textureMat);
```

# DistortionMeshBuffer

```
RenderManager::OpenResults RenderManagerOpenGL::OpenDisplay(void) {
	if (!UpdateDistortionMeshesInternal(SQUARE,
                                            m_params.m_distortionParameters)) {
	}
}

bool RenderManagerOpenGL::UpdateDistortionMeshesInternal(
    DistortionMeshType type ///< Type of mesh to produce
    ,
    std::vector<DistortionParameters> const&
        distort ///< Distortion parameters
    ) {

        // Compute the distortion mesh
        DistortionMesh mesh = ComputeDistortionMesh(eye, type, distort[eye], m_params.m_renderOverfillFactor);
        
	}
}

DistortionMesh ComputeDistortionMesh(size_t eye, DistortionMeshType type, DistortionParameters distort, float overfillFactor) {
          // Generate a grid of vertices with distorted texture coordinates
          for (int x = 0; x < numVertsPerSide; x++) {
              float xPos = -1 + x * quadSide;
              float xTex = x * quadTexSide;

              for (int y = 0; y < numVertsPerSide; y++) {
                  float yPos = -1 + y * quadSide;
                  float yTex = y * quadTexSide;

                  Float2 pos = { xPos, yPos };
                  Float2 tex = { xTex, yTex };

                  ret.vertices.emplace_back(pos,
                      DistortionCorrectTextureCoordinate(eye, tex, distort, 0, overfillFactor, interpolators),
                      DistortionCorrectTextureCoordinate(eye, tex, distort, 1, overfillFactor, interpolators),
                      DistortionCorrectTextureCoordinate(eye, tex, distort, 2, overfillFactor, interpolators));
              }
          }
}
inline Float2 OSVR_RENDERMANAGER_EXPORT DistortionCorrectTextureCoordinate(
    const size_t eye, Float2 const& inCoords,
    const DistortionParameters& distort, const size_t color,
    const float overfillFactor,
    const std::vector< std::unique_ptr<UnstructuredMeshInterpolator> >& interpolators) {
    using Eigen::Vector2f;
    using Eigen::Map;
    const auto inMap = Map<const Vector2f>(inCoords.data());

    Vector2f xyN = (inMap - Vector2f::Constant(0.5f)) * overfillFactor +
                   Vector2f::Constant(0.5f);
    const float xN = xyN.x();
    const float yN = xyN.y();

    const auto normalized_inCoords = Float2{xN, yN};

    Float2 ret = DistortionCorrectNormalizedTextureCoordinate(
        eye, normalized_inCoords, distort, color, interpolators);

    // Convert from unit (normalized) space back into overfill space.
    ret[0] = (ret[0] - 0.5f) / overfillFactor + 0.5f;
    ret[1] = (ret[1] - 0.5f) / overfillFactor + 0.5f;

    return ret;
}
```


