extends "res://logic/tiles/basicTiles/baseTile.gd"

func _ready():
	type = BLOCK
	is_pushable = true
	is_breakable = true

func add_prev_position():
	prev_positions.append([world_pos, exist])

func remove_obj():
	exist = false
	$Pivot/PlayerSprite.hide()

func readd_obj():
	exist = true
	$Pivot/PlayerSprite.show()

func move(input_direction):
	var target = world_pos + input_direction
	var tile_obj = Grid.get_cell_child(target)

	if tile_obj and tile_obj.exist:
		if tile_obj.type == BOMB:
			remove_obj()
			tile_obj.remove_obj()
		elif tile_obj and tile_obj.is_pushable() and tile_obj.exist:
			tile_obj.move(input_direction)
		
	animate_movement(target)

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

func animate_movement(target):
	if world_pos != target:
		Grid.set_process(false)
		$AnimationPlayer.play("Walk")
		var prev_pos = world_pos
		world_pos = target
		$Pivot.position = (prev_pos - target) * 64
		$Tween.interpolate_property($Pivot, "position", (prev_pos - target) * 64, Vector2(), $AnimationPlayer.current_animation_length, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
		position = Grid.map_to_world(world_pos) + Grid.cell_size / 2
		yield($AnimationPlayer, "animation_finished")
		Grid.set_process(true)