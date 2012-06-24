/* Copyright (c) 2012 Cheery
 *
 * See the file license.txt for copying permission. */
import sys, videosys, oes, time
from array import array
from PIL import Image

image = Image.open('logo.png')
image_width, image_height = image.size
image_data = image.tostring()

image_attr = (image_width, image_height, image_data)

fsrc = open("fragment.shader").read()
vsrc = open("vertex.shader").read()

triangle_data = [
    0.0, 0.0, 0.0,   0.0, 0.0,
    0.5, 0.0, 0.0,   1.0, 0.0,
    0.5, 0.5, 0.0,   1.0, 1.0,

    0.0, 0.0, 0.0,   0.0, 0.0,
    0.5, 0.5, 0.0,   1.0, 1.0,
    0.0, 0.5, 0.0,   0.0, 1.0,
]
data = array('f', triangle_data).tostring()

display = videosys.Display()
context = display.create_context()
surface = display.create_window(videosys.fullscreen(0))
context.make_current(surface)

triangle = oes.Drawable(oes.TRIANGLES, dict(
    position=(3,0,5),
    texcoord=(2,3,5),
))
triangle.upload(data)

oes.enable(oes.TEXTURE_2D)

texture = oes.Texture2D()
texture.bind(0)
texture.upload(*image_attr)
texture.linear()

program = oes.Shader((fsrc, vsrc))

oes.clearColor(0.15, 0.25, 0.35, 1.0)
oes.clear(oes.COLOR_BUFFER_BIT)

program.use()
program.i('texture', 0)

triangle.draw(program, 0, 6)

surface.swap_buffers()

time.sleep(2)
sys.exit(0)

#unused features:
# display.create_global_pixmap(width, height)  -  create pixmap that other processes can read, returning surface object has .handle you can read.
# image = display.create_global_image(handle)  -  access the global image
# image.target_texture(texture.target)         -  make a texture from the global image, (the texture must be bound)

# there's more details in the sources, if you dare to look into them.
