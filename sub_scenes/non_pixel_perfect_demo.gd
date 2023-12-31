extends Node2D

## Whether to use the debug player camera for testing. Otherwise, use the CameraController with non-pixel-perfect settings (hard-coded zoom).
@export var use_debug_player_camera: bool = false

func _ready() -> void:
	var camera_controller: CameraController = get_tree().get_first_node_in_group("camera_controllers")
	if use_debug_player_camera:
		var debug_player_camera: Camera2D = get_tree().get_first_node_in_group("debug_player_camera")
		camera_controller.enabled = false
		debug_player_camera.enabled = true
	else:
		# Hard-code a zoom for demo purposes. This is a 6x zoom from 320x180 to 1920x1080.
		camera_controller.zoom = Vector2(6, 6)
		# Disable pixel snapping.
		camera_controller.pixel_snap = false

	var player: Node = get_tree().get_first_node_in_group("player")
	# Disable pixel snap on player interpolator.
	player.get_node("Smoothing2D").set_pixel_snap(false)
