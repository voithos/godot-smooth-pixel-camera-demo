extends Label

@export var prefix: String = "Frame"

func _process(_delta: float) -> void:
	text = prefix + " " + str(Engine.get_frames_drawn() + 1)
