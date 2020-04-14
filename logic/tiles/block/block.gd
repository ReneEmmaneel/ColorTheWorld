# block.gd
#
# The script for block.tscn, as well as the parent script for all pushable objects
# It contains the code to animate the tile
# The move function contains a base function,
# as well as the following functions which should probably be overridden by child tiles:
# -move_into: triggers when TILE moves into given block
# -moved_into: triggers when TILE moves into self
# -custom_move: triggers at the end of move function

extends "res://logic/tiles/basicTiles/baseTile.gd"

func _ready():
	type = BLOCK
	is_pushable = true
	is_breakable = true

func animate_movement(prev_pos, target):
	if prev_pos != target:
		Grid.set_process(false)
		$AnimationPlayer.play("Walk")
		world_pos = target
		$Pivot.position = (prev_pos - target) * 64
		$Tween.interpolate_property($Pivot, "position", (prev_pos - target) * 64, Vector2(), $AnimationPlayer.current_animation_length, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
		position = Grid.map_to_world(world_pos) + Grid.cell_size / 2
		yield($AnimationPlayer, "animation_finished")
		Grid.set_process(true)

# move function
func move(direction):
	var target = world_pos + direction
	var tile_obj = Grid.get_cell_child(target)
	var tile_bg_obj = Grid.get_cell_background_child(target)

	if tile_obj and tile_obj.exist:
		move_into(tile_obj, direction)
	custom_move(tile_obj, direction)
	world_pos = target

#function that triggers when the tile is being moved towars tile_obj in the given direction
#the standard function does nothing special, 
#and just calls the moved_into function from the receiving tile_obj
func move_into(tile_obj, direction):
	tile_obj.moved_into(self, direction)

func moved_into(prev_obj, direction):
	move(direction)

func custom_move(tile_obj, direction):
	return