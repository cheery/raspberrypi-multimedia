/* Copyright (c) 2012 Cheery
 *
 * See the file license.txt for copying permission. */
from array import array

DEPTH_BUFFER_BIT = GL_DEPTH_BUFFER_BIT
STENCIL_BUFFER_BIT = GL_STENCIL_BUFFER_BIT
COLOR_BUFFER_BIT = GL_COLOR_BUFFER_BIT

from libc.stdlib cimport malloc, free

def clear(which):
    glClear(which)

def clearColor(r, g, b, a):
    glClearColor(r,g,b,a)

def clearDepth(depth):
    glClearDepthf(depth)

def clearStencil(value):
    glClearStencil(value)

def getProgramInfoLog(shader):
    cdef GLsizei maxLength, length
    glGetProgramiv(shader, GL_INFO_LOG_LENGTH, &maxLength)
    cdef GLchar* data = <GLchar*>malloc(maxLength)
    glGetProgramInfoLog(shader, maxLength, &length, data)
    log = str(<char*>data)
    free(data)
    return log, length

def getShaderInfoLog(shader):
    cdef GLsizei maxLength, length
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &maxLength)
    cdef GLchar* data = <GLchar*>malloc(maxLength)
    glGetShaderInfoLog(shader, maxLength, &length, data)
    log = str(<char*>data)
    free(data)
    return log, length

def getShaderi(shader, key):
    cdef GLint res
    glGetShaderiv(shader, key, &res)
    return res

def getProgrami(program, key):
    cdef GLint res
    glGetProgramiv(program, key, &res)
    return res

def enableVertexAttribArray(location):
    if location >= 0:
        glEnableVertexAttribArray(location)

def disableVertexAttribArray(location):
    if location >= 0:
        glDisableVertexAttribArray(location)

class Shader(object):
    def __init__(self, sources):
        self.program = glCreateProgram()
        self.vs = glCreateShader(GL_VERTEX_SHADER)
        self.fs = glCreateShader(GL_FRAGMENT_SHADER)
        glAttachShader(self.program, self.vs)
        glAttachShader(self.program, self.fs)

        self.link(sources)

        self.attrib_cache = {}
        self.uniform_cache = {}

    def link(self, sources):
        frag, vert = sources
        self.compile(self.vs, vert)
        self.compile(self.fs, frag)

        glLinkProgram(self.program)
        if GL_FALSE == getProgrami(self.program, GL_LINK_STATUS):
            raise Exception(getProgramInfoLog(self.program))

    def compile(self, shader, source):
        cdef char* string = source
        cdef int length = len(source)
        
        glShaderSource(shader, 1, &string, &length)
        glCompileShader(shader)
        if GL_FALSE == getShaderi(shader, GL_COMPILE_STATUS):
            raise Exception(getShaderInfoLog(shader))

    def attribLoc(self, name):
        loc = self.attrib_cache.get(name)
        if loc is None:
            loc = self.attrib_cache[name] = glGetAttribLocation(self.program, <char*>name)
        return loc

    def loc(self, name):
        loc = self.uniform_cache.get(name)
        if loc is None:
            loc = self.uniform_cache[name] = glGetUniformLocation(self.program, <char*>name)
        return loc

    def use(self):
        glUseProgram(self.program)

    def i(self, name, value):
        loc = self.loc(name)
        if loc >= 0:
            glUniform1i(loc, value)

    def f(self, name, value):
        loc = self.loc(name)
        if loc >= 0:
            glUniform1f(loc, value)

    def val2(self, name, a, b):
        loc = self.loc(name)
        if loc >= 0:
            glUniform2f(loc, a, b)

    def val3(self, name, a, b, c):
        loc = self.loc(name)
        if loc >= 0:
            glUniform3f(loc, a, b, c)

    def mat3(self, name, matrix):
        cdef GLfloat tmp[9]
        loc = self.loc(name)
        if loc >= 0:
            it = iter(matrix)
            for i in range(9):
                tmp[i] = <float>it.next()
            glUniformMatrix3fv(loc, 3, <int>GL_FALSE, tmp)

    def mat4(self, name, matrix):
        cdef GLfloat tmp[16]
        loc = self.loc(name)
        if loc >= 0:
            it = iter(matrix)
            for i in range(16):
                tmp[i] = <float>it.next()
            glUniformMatrix4fv(loc, 4, <int>GL_FALSE, tmp)

def createBuffer():
    cdef GLuint ids[1]
    glGenBuffers(1, ids)
    return ids[0]

POINTS = GL_POINTS
LINES = GL_LINES
LINE_LOOP = GL_LINE_LOOP
LINE_STRIP = GL_LINE_STRIP
TRIANGLES = GL_TRIANGLES
TRIANGLE_STRIP = GL_TRIANGLE_STRIP
TRIANGLE_FAN = GL_TRIANGLE_FAN

float_size = 4
class Drawable(object):
    def __init__(self, mode, attribs):
        self.mode = mode
        self.attribs = attribs
        self.id = createBuffer()
        self.size = 0

    def setPointer(self, shader, name, size=3, start=0, stride=0):
        loc = shader.attribLoc(name)
        enableVertexAttribArray(loc)
        if loc >= 0:
            glVertexAttribPointer(loc, size, GL_FLOAT, GL_FALSE, stride*float_size, <void*><GLint>(start*float_size))

    def disableAttribs(self, shader):
        for name in self.attribs:
            loc = shader.attribLoc(name)
            disableVertexAttribArray(loc)
            
    def draw(self, shader, first=0, size=None):
        size = self.size if size is None else size
        glBindBuffer(GL_ARRAY_BUFFER, self.id)
        for name, args in self.attribs.items():
            self.setPointer(shader, name, *args)
        glDrawArrays(self.mode, first, size)
        self.disableAttribs(shader)
        glBindBuffer(GL_ARRAY_BUFFER, 0)

    def uploadList(self, lst):
        self.uploadArray(array('f', lst))

    def uploadArray(self, arr):
        address, count = arr.buffer_info()
        length = count * arr.itemsize
        glBindBuffer(GL_ARRAY_BUFFER, self.id)
        glBufferData(GL_ARRAY_BUFFER, length, <void*><unsigned long>address, GL_STATIC_DRAW)
        glBindBuffer(GL_ARRAY_BUFFER, 0)

    def upload(self, data):
        length = len(data)
        glBindBuffer(GL_ARRAY_BUFFER, self.id)
        glBufferData(GL_ARRAY_BUFFER, length, <char*>data, GL_STATIC_DRAW)
        glBindBuffer(GL_ARRAY_BUFFER, 0)

def getError():
    value = glGetError()
    if value != GL_NO_ERROR:
        return {
            GL_INVALID_ENUM: "invalid enum",
            GL_INVALID_VALUE: "invalid value",
            GL_INVALID_OPERATION: "invalid operation",
            GL_OUT_OF_MEMORY: "out of memory",
        }.get(value, value)

def createTexture():
    cdef GLuint id
    glGenTextures(1, &id)
    return id

class Texture(object):
    def mipmap(self):
        glTexParameteri(self.target, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
        glTexParameteri(self.target, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
        glGenerateMipmap(self.target)
    
    def mipmapNearest(self):
        glTexParameteri(self.target, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
        glTexParameteri(self.target, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
        glGenerateMipmap(self.target)

    def linear(self):
        glTexParameteri(self.target, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
        glTexParameteri(self.target, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    
    def nearest(self):
        glTexParameteri(self.target, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
        glTexParameteri(self.target, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
    
    def clampToEdge(self):
        glTexParameteri(self.target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
        glTexParameteri(self.target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
    
    def repeat(self):
        glTexParameteri(self.target, GL_TEXTURE_WRAP_S, GL_REPEAT)
        glTexParameteri(self.target, GL_TEXTURE_WRAP_T, GL_REPEAT)

class Texture2D(Texture):
    target = GL_TEXTURE_2D
    def __init__(self):
        self.id = createTexture()
        self.width = 0
        self.height = 0

    def bind(self, unit=0):
        glActiveTexture(GL_TEXTURE0 + unit)
        glBindTexture(self.target, self.id)

    def upload(self, width, height, data):
        glTexImage2D(self.target, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, <char*>data)
        self.width = width
        self.height = height
    
    def setSize(self, width, height):
        glTexImage2D(self.target, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL)
        self.width = width
        self.height = height

def enable(cap):
    glEnable(cap)

def disable(cap):
    glDisable(cap)

TEXTURE_2D = GL_TEXTURE_2D
CULL_FACE = GL_CULL_FACE
BLEND = GL_BLEND
DITHER = GL_DITHER
STENCIL_TEST = GL_STENCIL_TEST
DEPTH_TEST = GL_DEPTH_TEST
SCISSOR_TEST = GL_SCISSOR_TEST
POLYGON_OFFSET_FILL = GL_POLYGON_OFFSET_FILL
SAMPLE_ALPHA_TO_COVERAGE = GL_SAMPLE_ALPHA_TO_COVERAGE
SAMPLE_COVERAGE = GL_SAMPLE_COVERAGE
