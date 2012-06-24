/* Copyright (c) 2012 Cheery
 *
 * See the file license.txt for copying permission. */
cdef encode_handle(char* handle, int count):
    out = ""
    for i in range(count):
        out += chr(handle[i])
    return out

def fullscreen(id=0):
    cdef char handle[12]
    videosys_fullscreen(id, handle)
    return encode_handle(handle, 12)

cdef class Display(object):
    cdef videosys_display_p display
    def __init__(self):
        self.display = videosys_get_display()

    def create_context(self, version=2):
        context = Context()
        context.context = videosys_create_context(
            self.display,
            version,
        )
        return context

    def create_window(self, handle):
        surface = Surface()
        surface.surface = videosys_create_window(
            self.display,
            <char*>handle
        )
        return surface

    def create_global_pixmap(self, width, height):
        cdef char handle[20]
        pixmap = videosys_create_shared_pixmap(self.display, width, height, handle)
        surface = Surface()
        surface.surface = pixmap
        surface.handle = encode_handle(handle, 20)
        return surface

    def create_global_image(self, handle):
        image = GlobalImage()
        image.global_image = videosys_create_global_image(self.display, <char*>handle)
        image.width = videosys_get_width(image.global_image)
        image.height = videosys_get_height(image.global_image)
        return image

cdef class Context(object):
    cdef videosys_context_p context
    def make_current(self, draw, read=None):
        cdef Surface d = draw
        cdef Surface r = read or draw
        videosys_context_make_current(
            self.context,
            d.surface,
            r.surface,
        )
        
cdef class Surface(object):
    cdef videosys_surface_p surface
    cdef public handle

    @property
    def width(self):
        return videosys_get_width(self.surface)

    @property
    def height(self):
        return videosys_get_height(self.surface)

    def swap_buffers(self):
        videosys_surface_swap_buffers(self.surface)

cdef class GlobalImage(object):
    cdef videosys_global_image_p global_image
    cdef public int width, height

    def target_texture(self, which):
        videosys_image_target_texture(which, self.global_image)

    def free(self):
        videosys_destroy_global_image(self.global_image)
