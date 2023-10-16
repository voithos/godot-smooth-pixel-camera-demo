extends Sprite2D

func _ready() -> void:
	# It's important that this script gets processed _after_ the "game scene", which includes the camera controller.
	# That is why we have placed it after the SubViewport. While we're at it, we can
	# use a larger priority number so that this node gets processed later in the process graph.
	process_priority = 10

func _physics_process(delta: float) -> void:
	# Set the pixel snap delta from the camera so that we can have smooth camera movement.
	var pixel_snap_delta := Vector2.ZERO
	var result: Node = get_tree().get_first_node_in_group("camera_controllers")
	if result and result is CameraController:
		pixel_snap_delta = result.get_pixel_snap_delta()
	material.set_shader_parameter("pixel_snap_delta", pixel_snap_delta)
