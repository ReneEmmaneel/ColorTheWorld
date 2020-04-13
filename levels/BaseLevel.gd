extends Node2D

func get_level() -> int:
	return get_tree().get_current_scene().get_name().right(5).to_int()

func _ready():
	pass