#When KEY tile is pushed into DOOR tile, remove both
#logic for this interaction is handled in DOOR tile

extends "res://logic/tiles/block/block.gd"

func _ready():
	exist = true
	is_breakable = true
	type = KEY

func custom_currently_pushable(tile_obj, direction) -> bool:
	return tile_obj and tile_obj.type == DOOR