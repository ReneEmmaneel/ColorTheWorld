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
		menu_instance.rect_scale = $Camera2D.zoom
		add_child(menu_instance)

func back_to_titlescreen():
	get_tree().change_scene("res://menu/titleScreen/TitleScreen.tscn")

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		cancel_pressed()
