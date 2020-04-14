extends "res://logic/tiles/basicTiles/baseTile.gd"

func _ready():
	is_pushable = false
	is_breakable = false
	type = ICE

func move_into(tile_obj, direction):
	print("hey")