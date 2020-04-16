#BOMB tile is pushable when it is pushed into something breakable
#When it is pushed into something breakable, or something breakable is pushed into BOMB,
#remove both

extends "res://logic/tiles/block/block.gd"

func _ready():
	exist = true
	is_breakable = true
	type = BOMB

func custom_currently_pushable(tile_obj, direction) -> bool:
	return tile_obj and tile_obj.is_breakable()

func move_into(tile_obj, direction):
	if tile_obj.is_breakable():
		tile_obj.remove_obj()
		self.remove_obj()
	else:
		tile_obj.moved_into(self, direction)

func moved_into(prev_obj, direction):
	if prev_obj.is_breakable():
		prev_obj.remove_obj()
		self.remove_obj()
	else:
		move(direction)
