class_name CameraController
extends Camera2D

## The current target being followed.
var _active_target: CameraTarget

## The previous actual-position the camera was set at.
var _previous_position: Vector2
## The previous pixel-snapped position. If pixel snap is disabled, this is the same as _previous_position.
var _previous_snapped_position: Vector2

func _ready() -> void:
	# Add to group so we can look it up later.
	add_to_group("camera_controllers")

func _physics_process(delta: float) -> void:
	if not _active_target:
		return
	# Update position.
	var target_position := _active_target.global_position
	var next_position: Vector2

	# Replace this with any smooth follow / lerp of your choosing.
	next_position.x = lerp(_previous_position.x, target_position.x, delta)
	next_position.y = lerp(_previous_position.y, target_position.y, delta)

	_previous_position = next_position

	# Important: perform pixel snap so that the camera movement doesn't interfere with the
	# sub-pixel "smooth movement" we do in the shader.
	next_position = next_position.round()

	_previous_snapped_position = next_position

	# Set the camera position.
	global_position = next_position

## Returns the position delta between the pixel-snapped position and the actual controlled camera position.
func get_pixel_snap_delta() -> Vector2:
	return _previous_position - _previous_snapped_position

## Registers a camera target to follow.
func register_target(target: CameraTarget) -> void:
	assert(not _active_target)
	_active_target = target
	_previous_position = _active_target.global_position
	_previous_snapped_position = _active_target.global_position.round()
