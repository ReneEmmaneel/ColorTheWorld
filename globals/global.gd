extends Node

var levels_beaten = []
var last_level = 0

var animation_speed = 0.15

var debug_show_all_levels = false
var debug_start_muted = true

func _ready():
	pass

func level_beaten(level):
	last_level = level
	if !(level in levels_beaten):
		levels_beaten.append(level)

func level_not_beaten(level):
	last_level = level
