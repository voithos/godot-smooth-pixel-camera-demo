extends CharacterBody2D


## IMPORTANT: The player speed effects whether or not you'll get _player_ jitter for a pixel-perfect
## game (you should never get jitter for non-moving sprites).
## To avoid jitter, the max steady-state velocity (when running at full speed, for example) would
## need to be an _even integer number of pixels_.
##
## In this example, the top speed is 120, which results in 2 pixels per frame when fps is capped at 60.
## If you instead capped fps to 120, it would result in 1 pixel movement per frame, which would still generally work.
## However, if your fps does not evenly divide (for example, if your fps was 144 in this case), that
## would mean that your steady-state speed will result in sub-pixel movement and that you'll get jitter
## because the player won't move the same number of pixels in every frame. This would be regardless of
## the particular camera smoothing options.
## In this example, the player would move SPEED / FPS, so 120 / 144 == 0.83 pixels per frame, and even
## with pixel snapping, this would result in inconsistent movement:
##
##   Frame:         1      2      3      4      5      6      7      8
##   Position:      0      0.83   1.66   2.5    3.33   4.16   5      5.83
##   Snapped:       0      1      2      3      3      4      5      6
##   Pixels moved:        +1     +1     +1     +0     +1     +1     +1
##                                             ^jitter!
const SPEED = 120.0
const JUMP_VELOCITY = -250.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

## Whether to snap to pixels during physics interpolation.
@onready var pixel_snap: bool = true

func _unhandled_input(_event: InputEvent) -> void:
	# Debug hotkeys.
	if Input.is_key_pressed(KEY_3):
		pixel_snap = not pixel_snap
		$Smoothing2D.set_pixel_snap(pixel_snap)
		print('Player pixel snap: ', pixel_snap)

	if Input.is_key_pressed(KEY_4):
		$Smoothing2D.set_enabled(not $Smoothing2D.is_enabled())
		print('Player physics interpolation: ', $Smoothing2D.is_enabled())

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if velocity.x != 0:
		%Sprite2D.flip_h = velocity.x > 0
	move_and_slide()

	# ADDED: Snap to a whole floor pixel if we're on the floor.
	# move_and_slide() keeps a tiny boundary between collision shapes, which can cause sporadic
	# jitter with smooth camera interpolation. It's less of an issue when rendering to small pixel
	# sizes, but can lead to visible 1px boundaries in the non_pixel_perfect_demo scene.
	if is_on_floor():
		global_position.y = floorf(global_position.y + 0.5)
