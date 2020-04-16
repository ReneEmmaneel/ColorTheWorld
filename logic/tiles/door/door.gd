extends "res://logic/tiles/basicTiles/baseTile.gd"

func _ready():
	type = DOOR
	exist = true

func moved_into(prev_obj, direction):
	if prev_obj.type == KEY:
		prev_obj.remove_obj()
		self.remove_obj()
