extends Node2D

var paused = false
var menu_instance = null

func is_paused():
	return paused

func cancel_pressed():
	if paused:
		paused = false
		remove_child(menu_instance)
	else:
		paused = true
		var menu = load("res://menu/worldMenu/WorldMenu.tscn")
		menu_instance = menu.instance()
		menu_instance.set_position($Camera2D.offset)
		add_child(menu_instance)

func back_to_titlescreen():
	get_tree().change_scene("res://menu/titleScreen/TitleScreen.tscn")

func _ready():
	pass
	#var world_level_instance = load_world_level("res://worldMap/WorldMapLevels/World1.tscn")
	#add_child(world_level_instance)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		cancel_pressed()

func load_world_level(path):
	var world_level = load(path)
	var world_level_instance = world_level.instance()
	return world_level_instance

func reset_worldmap():
	cancel_pressed()
	get_tree().reload_current_scene()
