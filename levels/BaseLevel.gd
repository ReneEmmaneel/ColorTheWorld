extends Node2D

# Extract the level number from its internal name
func get_level() -> int:
	return get_tree().get_current_scene().get_name().right(5).to_int()

func _ready():
	pass