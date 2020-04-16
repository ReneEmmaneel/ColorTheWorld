extends "res://logic/tiles/basicTiles/baseTile.gd"

var obj_to_move
var direction_to_move

func _ready():
	type = ICE
	exist = true

func move_into(prev_obj, direction):
	pass

func moved_into(prev_obj, direction):
	is_activated = true
	if prev_obj.is_player():
		obj_to_move = prev_obj
		direction_to_move = direction

func do_when_activated():
	pass
