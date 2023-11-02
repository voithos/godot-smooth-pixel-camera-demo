class_name CameraController
extends Camera2D

## Whether to use pixel snap.
@export var pixel_snap: bool = true
## Whether camera movement should be smooth.
@export var enable_smoothing: bool = true

## The current target being followed.
var _active_target: CameraTarget

var _previous_pixel_snap_delta := Vector2.ZERO
## The current camera velocity, for smooth damping.
var _current_velocity := Vector2.ZERO
## The current exact position of the camera.
var _current_position: Vector2


func _ready() -> void:
	# Add to group so we can look it up later.
	add_to_group("camera_controllers")

## Critically damped spring, based on Game Programming Gems 4 Chapter 1.10. https://archive.org/details/game-programming-gems-4/page/95/mode/2up
## Returns a 2-tuple of [next_position, next_velocity].
func smooth_damp(current: float, target: float, current_velocity: float, smooth_time: float, max_speed: float, delta: float) -> Array[float]:
	smooth_time = max(smooth_time, 0.0001)
	var omega := 2.0 / smooth_time

	var x := omega * delta
	var x_exp := 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x)
	var change := current - target
	var original_target := target

	# Clamp max speed.
	var max_change := max_speed * smooth_time
	change = clamp(change, -max_change, max_change)
	target = current - change

	var temp := (current_velocity + omega * change) * delta
	current_velocity = (current_velocity - omega * temp) * x_exp
	var output := target + (change + temp) * x_exp

	# Prevent overshooting.
	if (original_target - current > 0.0) == (output > original_target):
		output = original_target
		current_velocity = (output - original_target) / delta

	return [output, current_velocity]

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_1):
		pixel_snap = not pixel_snap
		print("Camera pixel snap: ", pixel_snap)
	if Input.is_key_pressed(KEY_2):
		enable_smoothing = not enable_smoothing
		print("Camera smoothing: ", enable_smoothing)

# It's important that the camera position gets updated in _process instead of _physics_process,
# since it needs to be dependent on frame rate.
func _process(delta: float) -> void:
	# Update position.
	var next_position: Vector2
	var target: Vector2 = _active_target.global_position

	if enable_smoothing:
		# Handle target movement with smooth_damp.
		# Replace this with any smooth follow / lerp of your choosing, but be careful to use `delta`
		# properly -- improper use can result in jitter. Don't do lerp(current, target, delta).
		var res_x := smooth_damp(_current_position.x, target.x, _current_velocity.x, 0.2, INF, delta)
		var res_y := smooth_damp(_current_position.y, target.y, _current_velocity.y, 0.2, INF, delta)
		next_position.x = res_x[0]
		next_position.y = res_y[0]
		_current_velocity.x = res_x[1]
		_current_velocity.y = res_y[1]
	else:
		# Set next camera position to the exact target.
		next_position = target

	_current_position = next_position

	if pixel_snap:
		# IMPORTANT: perform pixel snap so that the camera movement doesn't interfere with the
		# sub-pixel "smooth movement" we do in the shader.
		var snapped_position = (next_position + Vector2(0.5, 0.5)).floor()
		_previous_pixel_snap_delta = snapped_position - next_position
		next_position = snapped_position
	else:
		_previous_pixel_snap_delta = Vector2.ZERO

	# Set the camera position.
	global_position = next_position
	# IMPORTANT: Work around godot bug where camera doesn't update immediately: https://github.com/godotengine/godot/issues/74203
	force_update_scroll()

## Returns the position delta between the pixel-snapped position and the actual controlled camera position.
## If pixel snap is off, returns Zero.
func get_pixel_snap_delta() -> Vector2:
	return _previous_pixel_snap_delta

## Registers a camera target to follow.
func register_target(target: CameraTarget) -> void:
	assert(not _active_target)
	_active_target = target
	_current_position = _active_target.global_position
