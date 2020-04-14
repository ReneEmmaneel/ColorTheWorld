# baseTile.gd
#
# The parent script for all tiles.
# It has helper functions for getting various attributes of the tile
# It has a fuction that checks if the tile is currently pushable or moveable
# It also has functions which handle the redo functionality

extends Node2D

enum { EMPTY = -1, WALL, BLUE, GREY, BLOCK, KEY, DOOR, BOMB, WALL_CRACKED, ICE}
onready var Grid = get_parent()
var direction
var is_pushable = false
var is_player = false
var is_breakable = false
var is_background = false
var is_activated = false
var can_be_player = false
var type
var world_pos
var exist = true
var prev_positions = []

func is_pushable() -> bool:
	return is_pushable

func is_breakable() -> bool:
	return is_breakable

func is_background() -> bool:
	return is_background

func is_activated() -> bool:
	return is_activated

func is_player() -> bool:
	return is_player

func can_be_player() -> bool:
	return can_be_player

func set_direction(v2) -> void:
	direction = v2

func get_direction(v2) -> Vector2:
	return direction

# Returns true if the tile in the given direction is
# empty, the player or a pushable object that's currently pushable
func check_currently_pushable(direction) -> bool:
	var target = world_pos + direction
	var tile_obj = Grid.get_cell_child(target)

	if custom_currently_pushable(tile_obj, direction):
		return true
	elif !tile_obj or !tile_obj.exist:
		return true
	elif is_breakable() and tile_obj.type == BOMB:
		return true
	elif tile_obj.is_pushable():
		return tile_obj.check_currently_pushable(direction)
	return false

func custom_currently_pushable(tile_obj, direction) -> bool:
	return false

func is_possible_move(direction):
	var target = world_pos + direction
	if is_player():
		var tile_obj = Grid.get_cell_child(target)
		if !tile_obj or tile_obj.is_player() or !tile_obj.exist:
			return true
		if tile_obj.is_pushable():
			return tile_obj.check_currently_pushable(direction)
		return false
	return true

# Get the sprite of the current tile.
# There are 2 different possibilities:
# $Pivot/PlayerSprite (for movable tiles) (check this one first)
# $Sprite (For non movebale tiles)
func get_sprite() :
	if $Pivot/PlayerSprite != null:
		return $Pivot/PlayerSprite
	elif $Sprite != null:
		return $Sprite
	else:
		push_error("Sprite of tile not found")

func remove_obj():
	exist = false
	get_sprite().hide()

func readd_obj():
	exist = true
	get_sprite().show()

func add_prev_position():
	prev_positions.append([world_pos, exist])

func back_to_prev_position():
	if prev_positions.size() > 0:
		if exist != prev_positions[prev_positions.size() - 1][1]:
			if exist:
				remove_obj()
			else:
				readd_obj()
		animate_movement(world_pos, prev_positions[prev_positions.size() - 1][0])
		world_pos = prev_positions[prev_positions.size() - 1][0]
		prev_positions.remove(prev_positions.size() - 1)

# function should be overridden if object can move
func animate_movement(prev, curr):
	return

func move(direction) -> bool:
	return false

func moved_into(prev_obj, direction):
	return

func move_into(tile_obj, direction):
	return

func do_when_activated():
	return

func _ready():
	pass