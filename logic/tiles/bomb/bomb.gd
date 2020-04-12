extends "res://logic/tiles/block/block.gd"

func _ready():
	exist = true
	is_breakable = true
	type = BOMB

func check_currently_pushable(direction) -> bool:
	print("check pushable")
	var target = world_pos + direction
	var tile_obj = Grid.get_cell_child(target)
	if !tile_obj or tile_obj.is_player() or !tile_obj.exist:
		return true
	if tile_obj.type == BOMB:
		return true
	if tile_obj.is_breakable():
		return true
	if tile_obj.is_pushable():
		return tile_obj.check_currently_pushable(direction)
	return false

func add_prev_position():
	prev_positions.append([world_pos, exist])

func remove_obj():
	exist = false
	$Pivot/PlayerSprite.hide()

func readd_obj():
	exist = true
	$Pivot/PlayerSprite.show()

func back_to_prev_position():
	if prev_positions.size() > 0:
		if exist != prev_positions[prev_positions.size() - 1][1]:
			if exist:
				remove_obj()
			else:
				readd_obj() #this should never hit
		animate_movement(prev_positions[prev_positions.size() - 1][0])
		world_pos = prev_positions[prev_positions.size() - 1][0]
		prev_positions.remove(prev_positions.size() - 1)

func move(input_direction):
	var target = world_pos + input_direction
	var tile_obj = Grid.get_cell_child(target)
	if tile_obj:
		if tile_obj.is_breakable():
			remove_obj()
			tile_obj.remove_obj()
		elif tile_obj.is_pushable():
			tile_obj.move(input_direction)
	animate_movement(target)