extends "res://logic/tiles/basicTiles/baseTile.gd"
export(Texture) var grey_texture
export(Texture) var blue_texture

func _ready():
	is_pushable = true
	can_be_player = true
	type = GREY

func add_prev_position():
	prev_positions.append([world_pos, is_player])

func back_to_prev_position():
	if prev_positions.size() > 0:
		if is_player != prev_positions[prev_positions.size() - 1][1]:
			if is_player:
				remove_player()
			else:
				make_player() #this should never hit
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

func animate_win():
	$AnimationPlayer.play("Win")

func move(input_direction):
	var target = world_pos + input_direction
	var tile_obj = Grid.get_cell_child(target)
	if tile_obj and tile_obj.is_pushable() and tile_obj.exist:
		tile_obj.move(input_direction)

	animate_movement(target)

func make_player():
	is_player = true
	is_pushable = false
	$Pivot/PlayerSprite.texture = blue_texture

func remove_player():
	is_player = false
	is_pushable = true
	$Pivot/PlayerSprite.texture = grey_texture

func color_blue():
	for dir in [Vector2(1,0), Vector2(0,1), Vector2(-1, 0), Vector2(0, -1)]:
		var child = Grid.get_cell_child(world_pos + dir)
		if child and child.can_be_player and !child.is_player():
			child.make_player()
			child.color_blue()