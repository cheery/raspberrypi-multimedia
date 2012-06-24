ctypedef void* videosys_display_p
ctypedef void* videosys_context_p
ctypedef void* videosys_surface_p
ctypedef void* videosys_global_image_p
ctypedef unsigned int GLenum

cdef extern videosys_display_p videosys_get_display()
cdef extern void videosys_fullscreen(int id, void* native_window)
cdef extern videosys_context_p videosys_create_context(videosys_display_p display, int version)
cdef extern videosys_surface_p videosys_create_window(videosys_display_p display, void* native_window)
cdef extern void videosys_context_make_current(videosys_context_p context, videosys_surface_p read, videosys_surface_p write)
cdef extern void videosys_surface_swap_buffers(videosys_surface_p surface)
cdef extern videosys_surface_p videosys_create_shared_pixmap(videosys_display_p display, int width, int height, void* handle)
cdef extern videosys_global_image_p videosys_create_global_image(videosys_display_p display, void* handle)
cdef extern void videosys_destroy_global_image(videosys_global_image_p image)
cdef extern void videosys_image_target_texture(GLenum target, videosys_global_image_p image)
cdef extern unsigned int videosys_get_width(void* any)
cdef extern unsigned int videosys_get_height(void* any)
