extends Label

@export var prefix: String = "FPS"

func _process(_delta: float) -> void:
	text = prefix + " " + str(Engine.get_frames_per_second())
