class_name CameraTarget
extends Node2D

func _ready() -> void:
	# Attempt to register with controller.
	var result: Node = get_tree().get_first_node_in_group("camera_controllers")
	if result and result is CameraController:
		result.register_target(self)
