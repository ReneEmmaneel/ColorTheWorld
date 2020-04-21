extends Node

var levels_beaten = []
var last_level = 0

var animation_speed = 0.15

var debug_show_all_levels = true
var debug_start_muted = true
var debug_shorcuts = true

func _ready():
	pass

func get_screen_size():
	return get_viewport().size

func level_beaten(level):
	last_level = level
	if !(level in levels_beaten):
		levels_beaten.append(level)

func level_not_beaten(level):
	last_level = level

func _process(delta):
	if debug_shorcuts:
		if Input.is_action_just_pressed("ui_exit_game"):
			get_tree().quit()
