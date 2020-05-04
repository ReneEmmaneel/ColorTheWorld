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
	record_last_move = true

func animate_movement(prev_pos, target, hide):
	custom_animate_movement()
	if prev_pos == null or target == null:
		return
	var length = target - prev_pos
	if length.length() > 0:
		#$AnimationPlayer.get_animation("Walk").length = 0.2 * length.length()
		$AnimationPlayer.play("Walk")
		world_pos = target
		$Pivot.position = (prev_pos - target) * 64
		$Tween.interpolate_property($Pivot, "position", (prev_pos - target) * 64, Vector2(), global.animation_speed, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
		position = Grid.map_to_world(world_pos) + Grid.cell_size / 2
		yield($Tween, "tween_completed")
		if hide:
			$Pivot/PlayerSprite.hide()

func custom_animate_movement():
	pass

# move function
func move(direction):
	var target = world_pos + direction
	for tile_obj in Grid.get_cell_child(target):
		if tile_obj == null:
			return #should not exist
		if tile_obj and tile_obj.exist:
			move_into(tile_obj, direction)
		custom_move(tile_obj, direction)
	world_pos = target

#function that triggers when the tile is being moved towars tile_obj in the given direction
#the standard function does nothing special,
#and just calls the moved_into function from the receiving tile_obj
func move_into(tile_obj, direction):
	tile_obj.move_direction = move_direction if move_direction != null else direction
	tile_obj.moved_into(self, direction)

func moved_into(prev_obj, direction):
	move_direction = direction
	move(direction)

func custom_move(tile_obj, direction):
	return
