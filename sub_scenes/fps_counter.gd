extends Label

@export var prefix: String = "FPS"

func _process(delta: float) -> void:
	text = prefix + " " + str(Engine.get_frames_per_second())
