extends "res://logic/tiles/basicTiles/baseTile.gd"

var direction_facing = Vector2(1,0)

func _ready():
	type = global.Tiles.PISTON
	record_last_move = false

func extend_piston():
	var Grid = get_parent()
	var pushable = true
	for child in Grid.get_cell_child(world_pos + direction_facing):
		if child.check_currently_pushable(direction_facing):
			child.move(direction_facing)
		else:
			pushable = false
	is_activated = true
	$Sprite.frame = 1

func retract_piston():
	is_activated = false
	$Sprite.frame = 0
