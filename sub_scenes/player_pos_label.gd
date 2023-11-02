extends Label


func _process(delta: float) -> void:
	var sprite := get_tree().get_first_node_in_group("player_sprite")
	text = "Player: " + str(sprite.global_position)
