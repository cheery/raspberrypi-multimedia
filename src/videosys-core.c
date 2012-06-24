/* Copyright (c) 2012 Cheery
 *
 * See the file license.txt for copying permission. */
#include "bcm_host.h"

#define EGL_EGLEXT_PROTOTYPES 1
#include "GLES/gl.h"
#include "EGL/egl.h"
#include "EGL/eglext.h"

#include <assert.h>

typedef struct {
	EGLDisplay display;
	EGLConfig config;
} videosys_display;

typedef videosys_display* videosys_display_p;
#define Display videosys_display_p

typedef struct {
	Display display;
	EGLContext context;
} videosys_context;

typedef videosys_context* videosys_context_p;
#define Context videosys_context_p

typedef struct {
	uint32_t width, height;
	Display display;
	EGLSurface surface;
} videosys_surface;

typedef videosys_surface* videosys_surface_p;
#define Surface videosys_surface_p

typedef struct {
	int width;
	int height;
	Display display;
	EGLImageKHR image;
} videosys_global_image;

typedef videosys_global_image* videosys_global_image_p;
#define GlobalImage videosys_global_image_p

Display videosys_get_display() {
	EGLBoolean result;
	EGLDisplay display;
	EGLConfig config;

	EGLint num_config;
	static const EGLint attributes[] = {
		EGL_RED_SIZE, 8,
		EGL_GREEN_SIZE, 8,
		EGL_BLUE_SIZE, 8,
		EGL_ALPHA_SIZE, 8,
		EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
		EGL_NONE
	};
	
	display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
	assert(display != EGL_NO_DISPLAY);

	result = eglInitialize(display, NULL, NULL);
	assert(result != EGL_FALSE);

	result = eglChooseConfig(display, attributes, &config, 1, &num_config);
	assert(result != EGL_FALSE);

	Display g = malloc(sizeof(*g));
	g->display = display;
	g->config = config;
	return g;
}

void videosys_fullscreen(int id, void* native_window){
	int success;
    uint32_t width, height;
	
	bcm_host_init();
	
	success = graphics_get_display_size(id, &width, &height);
	assert(success >= 0);

	DISPMANX_ELEMENT_HANDLE_T element;
	DISPMANX_DISPLAY_HANDLE_T display;
	DISPMANX_UPDATE_HANDLE_T update;
	VC_RECT_T dst_rect;
	VC_RECT_T src_rect;
	
	vc_dispmanx_rect_set(&dst_rect, 0, 0, width, height);
	vc_dispmanx_rect_set(&src_rect, 0, 0, width<<16, height<<16);

	display = vc_dispmanx_display_open(id);
	update = vc_dispmanx_update_start(0);
	element = vc_dispmanx_element_add(
		update, display, 0/*layer*/,
		&dst_rect, 0/*src*/, &src_rect,
		DISPMANX_PROTECTION_NONE,
		0/*alpha*/,
		0/*clamp*/,
		0/*transform*/
	);
	vc_dispmanx_update_submit_sync(update);

	assert(sizeof(int) == 4);
	int* res = native_window;
        res[0] = element;
	res[1] = width;
	res[2] = height;
}

Context videosys_create_context(Display display, int version) {
	EGLContext context;
	assert(display != NULL);

	EGLint context_attributes[] = {
		EGL_CONTEXT_CLIENT_VERSION, version,
		EGL_NONE
	};

	context = eglCreateContext(display->display, display->config, EGL_NO_CONTEXT, context_attributes);
	assert(context != EGL_NO_CONTEXT);

	Context g = malloc(sizeof(*g));
	g->display = display;
	g->context = context;
	return g;
}

Surface videosys_create_window(Display display, void* native_window) {
	assert(sizeof(int) == 4);
	int* info = native_window;
	EGLSurface surface;

	surface = eglCreateWindowSurface(
		display->display,
		display->config,
		native_window,
		NULL
	);
	assert(surface != EGL_NO_SURFACE);

	Surface g = malloc(sizeof(*g));
	g->display = display;
	g->surface = surface;
	g->width = info[1];
	g->height = info[2];
	return g;
}

void videosys_context_make_current(Context context, Surface write, Surface read) {
	Display display = context->display;
	assert(context->display == read->display);
	assert(context->display == write->display);
	EGLBoolean res = eglMakeCurrent(display->display, write->surface, read->surface, context->context);
	
	assert(res == EGL_TRUE);
}

void videosys_surface_swap_buffers(Surface surface) {
	eglFlushBRCM();
	eglSwapBuffers(surface->display->display, surface->surface);
}

#define EGL_PIXEL_FORMAT_ARGB_8888_PRE_BRCM 0
#define EGL_PIXEL_FORMAT_ARGB_8888_BRCM     1
#define EGL_PIXEL_FORMAT_XRGB_8888_BRCM     2
#define EGL_PIXEL_FORMAT_RGB_565_BRCM       3
#define EGL_PIXEL_FORMAT_A_8_BRCM           4
#define EGL_PIXEL_FORMAT_RENDER_GL_BRCM     (1 << 3)
#define EGL_PIXEL_FORMAT_RENDER_GLES_BRCM   (1 << 4)
#define EGL_PIXEL_FORMAT_RENDER_GLES2_BRCM  (1 << 5)
#define EGL_PIXEL_FORMAT_RENDER_VG_BRCM     (1 << 6)
#define EGL_PIXEL_FORMAT_RENDER_MASK_BRCM   0x78
#define EGL_PIXEL_FORMAT_VG_IMAGE_BRCM      (1 << 7)
#define EGL_PIXEL_FORMAT_GLES_TEXTURE_BRCM  (1 << 8)
#define EGL_PIXEL_FORMAT_GLES2_TEXTURE_BRCM (1 << 9)
#define EGL_PIXEL_FORMAT_TEXTURE_MASK_BRCM  0x380
#define EGL_PIXEL_FORMAT_USAGE_MASK_BRCM    0x3f8

Surface videosys_create_shared_pixmap(Display display, int width, int height, void* handle) {
	assert(sizeof(int) == 4);

	EGLint pixel_format = EGL_PIXEL_FORMAT_ARGB_8888_BRCM;
	EGLint rt;
	eglGetConfigAttrib(
		display->display,
		display->config,
		EGL_RENDERABLE_TYPE,
		&rt
	);

	if (rt & EGL_OPENGL_ES_BIT) {
		pixel_format |= EGL_PIXEL_FORMAT_RENDER_GLES_BRCM;
		pixel_format |= EGL_PIXEL_FORMAT_GLES_TEXTURE_BRCM;
	}
	if (rt & EGL_OPENGL_ES2_BIT) {
		pixel_format |= EGL_PIXEL_FORMAT_RENDER_GLES2_BRCM;
		pixel_format |= EGL_PIXEL_FORMAT_GLES2_TEXTURE_BRCM;
	}
	if (rt & EGL_OPENVG_BIT) {
		pixel_format |= EGL_PIXEL_FORMAT_RENDER_VG_BRCM;
		pixel_format |= EGL_PIXEL_FORMAT_VG_IMAGE_BRCM;
	}
	if (rt & EGL_OPENGL_BIT) {
		pixel_format |= EGL_PIXEL_FORMAT_RENDER_GL_BRCM;
	}
	int* global_image = handle;
	global_image[0] = 0;
	global_image[1] = 0;
	global_image[2] = width;
	global_image[3] = height;
	global_image[4] = pixel_format;

	eglCreateGlobalImageBRCM(
		width,
		height,
		global_image[4],
		0,
		width*4,
		global_image
	);

	EGLint attrs[] = {
		EGL_VG_COLORSPACE, EGL_VG_COLORSPACE_sRGB,
		EGL_VG_ALPHA_FORMAT, pixel_format & EGL_PIXEL_FORMAT_ARGB_8888_PRE_BRCM ? EGL_VG_ALPHA_FORMAT_PRE : EGL_VG_ALPHA_FORMAT_NONPRE,
		EGL_NONE
	};
	
	EGLSurface surface = eglCreatePixmapSurface(
		display->display,
		display->config,
		(EGLNativePixmapType)global_image,
		attrs
	);
	assert(surface != EGL_NO_SURFACE);

	Surface g = malloc(sizeof(*g));
	g->display = display;
	g->surface = surface;
	g->width = width;
	g->height = height;
	return g;
}

GlobalImage videosys_create_global_image(Display display, void* handle) {
	int* global_image = handle;
	assert (eglQueryGlobalImageBRCM(global_image, global_image+2));

	EGLImageKHR image = (EGLImageKHR)eglCreateImageKHR(
		display->display,
		EGL_NO_CONTEXT,
		EGL_NATIVE_PIXMAP_KHR,
		(EGLClientBuffer)global_image,
		NULL
	);
	assert(image != EGL_NO_IMAGE_KHR);

	GlobalImage g = malloc(sizeof(*g));
	g->display = display;
	g->image = image;
	g->width = global_image[2];
	g->height = global_image[3];
	return g;
}

void videosys_destroy_global_image(GlobalImage image) {
	eglDestroyImageKHR(image->display->display, image->image);
}

void videosys_image_target_texture(GLenum target, GlobalImage image) {
    glEGLImageTargetTexture2DOES(target, image->image);
}

uint32_t videosys_get_width(void* any) {
	return 0[(uint32_t*)any];
}

uint32_t videosys_get_height(void* any) {
	return 1[(uint32_t*)any];
}
