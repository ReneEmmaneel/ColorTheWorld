extends "res://logic/tiles/basicTiles/baseTile.gd"

func _ready():
	type = WALL_CRACKED
	is_breakable = true
	record_last_move = true
