# Godot 4.1 Smooth Pixel Camera Demo

This repo is a **minimal** example on how to achieve one form on pixel-perfect
rendering with smooth camera movement on Godot 4.x (at the time of writing,
4.1).

Getting reasonable smooth camera movement with pixel-perfect upscaling is
[notoriously difficult in Godot 4](https://github.com/godotengine/godot-proposals/issues/6389).
The approach used in this repo is not perfect and has some limitations, but does
seem to get rid of ~most forms of jitter.

https://github.com/voithos/godot-smooth-pixel-camera-demo/assets/744228/af1183e9-26ff-4809-bcb3-f01e35b7da94

## How it works

Important: since this is a minimal example, the code is simplistic and strongly
coupled, with some hard-coded values to aid in understanding. Thus, it should be
used as an example to reproduce / expand upon, rather than to copy directly into
your own project.

---

The general idea used here is not new, and variants of it have been used and
documented by several others. Importantly, we don't use the project-level pixel
snap settings.

- We start with a `SubViewport` which houses the pixel-perfect rendered game.
  - We configure it with our target pixel-perfect size, plus a 1px extra border
    so that the smooth camera can move at "subpixels" (in the example, this is
    322x182).
  - We set `Default Texture Filter` to `Nearest` and enable
    `Snap 2D Vertices to Pixel`.
- In the scene inside the `SubViewport`, we define a camera _outside_ our player
  node, so that we can control smooth camera movement.
  - We create a `CameraTarget` in the player that just acts as a "target" for
    the camera to interpolate to.
  - In the `CameraController`, we keep track of a precise "virtual" position
    that the camera is currently at, but snap the actual `global_position` to
    whole integer pixels. We store the snapped position and the "virtual" true
    position so that we can calculate the precision that we lost when snapping.
- Instead of using a `SubViewportContainer`, we create a normal `Sprite2D` and
  point it at our `SubViewport` with a `ViewportTexture`.
  - We position it in the middle of the (full-res) display, and set the scaling
    appropriately so that it upscales to the full-res display.
  - We attach a special shader that handles the subpixel camera movement by
    sampling from the `SubViewport` texture. We pass in the "pixel snap delta",
    which is the difference between the true camera position and the
    pixel-snapped camera position.

## Limitations

### Limitations with the technique

- The `SubViewport` constrains all children to snap to whole pixels, so sprite
  movement is always constrained to whole pixels.
  - Other techniques exist which relax this constraint during motion and only
    "snap" when a sprite isn't moving, for example.
- Similarly, parallax motion in the `SubViewport` will be limited to whole
  pixels. It'd be possible to have smooth parallax, but it'd require separate
  `SubViewports` for each parallax layer, and a more complex shader to composite
  them together.

### Limitations in the demo

- The demo is hard coded to use a "pixel canvas size" of **320x180** for the
  pixel-perfect rendering, and to upscale it to a final window resolution of
  **1920x1080**. You'd want to be more flexible with the target size in an
  actual game.
- The upscaling assumes an integer size multiple (6x for the demo sizes),
  although there are other pixel art upscaling techniques you could use which
  can handle non-integer scaling gracefully.
- There's a [Godot bug](https://github.com/godotengine/godot/issues/66247) that
  noisily reports viewport texture errors if you open the scene with the
  `SubViewport` in it. As far as I can tell, it doesn't cause any issues at
  runtime.
