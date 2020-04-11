extends "res://logic/tiles/basicTiles/baseTile.gd"

func _ready():
	type = DOOR
	exist = true

func add_prev_position():
	prev_positions.append([world_pos, exist])

func remove_obj():
	exist = false
	$Sprite.hide()

func readd_obj():
	exist = true
	$Sprite.show()

func back_to_prev_position():
	if prev_positions.size() > 0:
		if exist != prev_positions[prev_positions.size() - 1][1]:
			if exist:
				remove_obj()
			else:
				readd_obj()
		world_pos = prev_positions[prev_positions.size() - 1][0]
		prev_positions.remove(prev_positions.size() - 1)