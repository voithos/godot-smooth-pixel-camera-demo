extends Label


func _process(_delta: float) -> void:
	var camera := get_tree().get_first_node_in_group("camera_controllers")
	text = "Camera: " + str(camera.global_position) + " +" + str(camera.get_pixel_snap_delta())
