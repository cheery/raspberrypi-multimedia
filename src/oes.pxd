ctypedef unsigned int GLbitfield
ctypedef float GLclampf
ctypedef int GLint
ctypedef int GLsizei
ctypedef unsigned int GLuint
ctypedef char GLchar
ctypedef unsigned int GLenum
ctypedef float GLfloat
ctypedef char GLboolean

cdef extern from "GLES2/gl2.h":
    # for clearing framebuffer
    enum GLClearBufferMask:
        GL_DEPTH_BUFFER_BIT
        GL_STENCIL_BUFFER_BIT
        GL_COLOR_BUFFER_BIT

    void glClear(GLbitfield)
    void glClearColor(GLclampf, GLclampf, GLclampf, GLclampf)
    void glClearDepthf(GLclampf)
    void glClearStencil(GLint)

    # program
    enum GLShaderSource:
        GL_COMPILE_STATUS
        GL_INFO_LOG_LENGTH
        GL_SHADER_SOURCE_LENGTH
        GL_SHADER_COMPILER

    enum GLShaders:
        GL_FRAGMENT_SHADER
        GL_VERTEX_SHADER
        GL_LINK_STATUS

    GLuint glCreateProgram()
    GLuint glCreateShader(GLenum)
    void glAttachShader(GLuint, GLuint)
    void glLinkProgram(GLuint)
    void glShaderSource(GLuint, GLsizei, char**, int*)
    void glCompileShader(GLuint)
    void glGetProgramiv(GLuint, GLenum, GLint*)
    void glGetShaderiv(GLuint, GLenum, GLint*)
    void glGetProgramInfoLog(GLuint, GLsizei, GLsizei*, GLchar*)
    void glGetShaderInfoLog(GLuint, GLsizei, GLsizei*, GLchar*)
    int glGetAttribLocation(GLuint, GLchar*)
    int glGetUniformLocation(GLuint, GLchar*)
    void glEnableVertexAttribArray(GLuint)
    void glDisableVertexAttribArray(GLuint)
    void glUseProgram(GLuint)

    void glUniform1i(GLint, GLint)
    void glUniform1f(GLint, GLfloat)
    void glUniform2f(GLint, GLfloat, GLfloat)
    void glUniform3f(GLint, GLfloat, GLfloat, GLfloat)
    void glUniformMatrix3fv(GLint, GLsizei, GLboolean, GLfloat*)
    void glUniformMatrix4fv(GLint, GLsizei, GLboolean, GLfloat*)

    # vbo
    enum GLBufferObjects:
        GL_ARRAY_BUFFER
        GL_ELEMENT_ARRAY_BUFFER

    enum GLUsage:
        GL_STREAM_DRAW
        GL_STATIC_DRAW
        GL_DYNAMIC_DRAW

    void glBindBuffer(GLenum, GLuint)
    void glBufferData(GLenum, GLsizei, void*, GLenum)
    void glVertexAttribPointer(GLuint, GLint, GLenum, GLboolean, GLsizei, void*)
    void glDrawArrays(GLenum, GLint, GLsizei)

    # buffers
    void glGenBuffers(GLsizei, GLuint*)

    # textures
    void glGenTextures(GLsizei, GLuint*)
    void glTexParameteri(GLenum, GLenum, GLenum)
    void glGenerateMipmap(GLenum)
    void glActiveTexture(GLenum)
    void glBindTexture(GLenum, GLuint)
    void glTexImage2D(GLenum, GLint, GLint, GLsizei, GLsizei, GLint, GLenum, GLenum, void*)
    
    enum GLBoolean:
        GL_TRUE
        GL_FALSE

    enum GLBeginMode:
        GL_POINTS
        GL_LINES
        GL_LINE_LOOP
        GL_LINE_STRIP
        GL_TRIANGLES
        GL_TRIANGLE_STRIP
        GL_TRIANGLE_FAN

    enum GLComparator:
        GL_NEVER
        GL_LESS
        GL_EQUAL
        GL_LEQUAL
        GL_GREATER
        GL_NOTEQUAL
        GL_GEQUAL
        GL_ALWAYS

    enum GLBlendingFactor:
        GL_ZERO
        GL_ONE
        GL_SRC_COLOR
        GL_ONE_MINUS_SRC_COLOR
        GL_SRC_ALPHA
        GL_ONE_MINUS_SRC_ALPHA
        GL_DST_ALPHA
        GL_ONE_MINUS_DST_ALPHA

    void glEnable(GLenum)
    void glDisable(GLenum)

    enum GLEnableCap:
        GL_TEXTURE_2D
        GL_CULL_FACE
        GL_BLEND
        GL_DITHER
        GL_STENCIL_TEST
        GL_DEPTH_TEST
        GL_SCISSOR_TEST
        GL_POLYGON_OFFSET_FILL
        GL_SAMPLE_ALPHA_TO_COVERAGE
        GL_SAMPLE_COVERAGE

    enum GLErrorCode:
        GL_NO_ERROR
        GL_INVALID_ENUM
        GL_INVALID_VALUE
        GL_INVALID_OPERATION
        GL_OUT_OF_MEMORY

    GLenum glGetError()

    enum GLDataType:
        GL_BYTE
        GL_UNSIGNED_BYTE
        GL_SHORT
        GL_UNSIGNED_SHORT
        GL_INT
        GL_UNSIGNED_INT
        GL_FLOAT
        GL_FIXED

    enum GLPixelFormat:
        GL_DEPTH_COMPONENT
        GL_ALPHA
        GL_RGB
        GL_RGBA
        GL_LUMINANCE
        GL_LUMINANCE_ALPHA

    enum GLTextureFilter:
        GL_NEAREST
        GL_LINEAR
        GL_NEAREST_MIPMAP_NEAREST
        GL_LINEAR_MIPMAP_NEAREST
        GL_NEAREST_MIPMAP_LINEAR
        GL_LINEAR_MIPMAP_LINEAR

    enum GLTextureParameterName:
        GL_TEXTURE_MAG_FILTER
        GL_TEXTURE_MIN_FILTER
        GL_TEXTURE_WRAP_S
        GL_TEXTURE_WRAP_T

    enum GLTextureTarget:
        GL_TEXTURE
        GL_TEXTURE_CUBE_MAP
        GL_TEXTURE_BINDING_CUBE_MAP
        GL_TEXTURE_CUBE_MAP_POSITIVE_X
        GL_TEXTURE_CUBE_MAP_NEGATIVE_X
        GL_TEXTURE_CUBE_MAP_POSITIVE_Y
        GL_TEXTURE_CUBE_MAP_NEGATIVE_Y
        GL_TEXTURE_CUBE_MAP_POSITIVE_Z
        GL_TEXTURE_CUBE_MAP_NEGATIVE_Z
        GL_MAX_CUBE_MAP_TEXTURE_SIZE

    enum GLTextureUnit:
        GL_TEXTURE0
        GL_TEXTURE1
        GL_TEXTURE2
        GL_TEXTURE3
        GL_TEXTURE4
        GL_TEXTURE5
        GL_TEXTURE6
        GL_TEXTURE7
        GL_TEXTURE8
        GL_TEXTURE9
        GL_TEXTURE10
        GL_TEXTURE11
        GL_TEXTURE12
        GL_TEXTURE13
        GL_TEXTURE14
        GL_TEXTURE15
        GL_TEXTURE16
        GL_TEXTURE17
        GL_TEXTURE18
        GL_TEXTURE19
        GL_TEXTURE20
        GL_TEXTURE21
        GL_TEXTURE22
        GL_TEXTURE23
        GL_TEXTURE24
        GL_TEXTURE25
        GL_TEXTURE26
        GL_TEXTURE27
        GL_TEXTURE28
        GL_TEXTURE29
        GL_TEXTURE30
        GL_TEXTURE31
        GL_ACTIVE_TEXTURE

    enum GLTextureWrapMode:
        GL_REPEAT
        GL_CLAMP_TO_EDGE
        GL_MIRRORED_REPEAT

    enum GLUniformTypes:
        GL_FLOAT_VEC2
        GL_FLOAT_VEC3
        GL_FLOAT_VEC4
        GL_INT_VEC2
        GL_INT_VEC3
        GL_INT_VEC4
        GL_BOOL
        GL_BOOL_VEC2
        GL_BOOL_VEC3
        GL_BOOL_VEC4
        GL_FLOAT_MAT2
        GL_FLOAT_MAT3
        GL_FLOAT_MAT4
        GL_SAMPLER_2D
        GL_SAMPLER_CUBE

