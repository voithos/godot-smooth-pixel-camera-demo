extends Node2D

@onready var sub_viewport: SubViewport = $SubViewport

func _unhandled_input(event: InputEvent) -> void:
	# SubViewports don't receive input by default, so we have to propagate it.
	sub_viewport.push_input(event)
