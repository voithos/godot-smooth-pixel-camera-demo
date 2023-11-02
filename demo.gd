extends Node2D

## Whether to use the debug player camera for testing. Otherwise, use the CameraController with non-pixel-perfect settings (hard-coded zoom).
@export var use_debug_player_camera: bool = false

func _ready() -> void:
	var camera_controller: CameraController = get_tree().get_first_node_in_group("camera_controllers")
	if use_debug_player_camera:
		var debug_player_camera: Camera2D = get_tree().get_first_node_in_group("debug_player_camera")
		camera_controller.enabled = false
		debug_player_camera.zoom = Vector2(1, 1)
		debug_player_camera.enabled = true
