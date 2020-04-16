extends Node2D

var paused = false
var menu_instance = false

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if paused:
			paused = false
			remove_child(menu_instance)
		else:
			paused = true
			var menu = load("res://menu/worldMenu/WorldMenu.tscn")
			menu_instance = menu.instance()
			add_child(menu_instance)
