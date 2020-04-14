extends "res://logic/tiles/block/block.gd"
export(Texture) var grey_texture
export(Texture) var blue_texture

func _ready():
	is_pushable = true
	is_breakable = false
	can_be_player = true
	type = GREY

#custom functions for prev position tracking, as the is_player status is important
func add_prev_position():
	prev_positions.append([world_pos, is_player])

func back_to_prev_position():
	if prev_positions.size() > 0:
		if is_player != prev_positions[prev_positions.size() - 1][1]:
			if is_player:
				remove_player()
			else:
				make_player()
		animate_movement(world_pos, prev_positions[prev_positions.size() - 1][0])
		world_pos = prev_positions[prev_positions.size() - 1][0]
		prev_positions.remove(prev_positions.size() - 1)

func make_player():
	is_player = true
	is_pushable = false
	$Pivot/PlayerSprite.texture = blue_texture

func remove_player():
	is_player = false
	is_pushable = true
	$Pivot/PlayerSprite.texture = grey_texture

#custom moved into function, when is_player == true, ignore move into
func moved_into(prev_obj, direction):
	if !is_player:
		move(direction)

#play win animation
func animate_win():
	$AnimationPlayer.play("Win")

#color all adjacent blobs blue
func color_blue():
	for dir in [Vector2(1,0), Vector2(0,1), Vector2(-1, 0), Vector2(0, -1)]:
		var child = Grid.get_cell_child(world_pos + dir)
		if child and child.can_be_player and !child.is_player():
			child.make_player()
			child.color_blue()