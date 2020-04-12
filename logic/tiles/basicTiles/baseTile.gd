extends Node2D

enum { EMPTY = -1, WALL, BLUE, GREY, BLOCK, KEY, DOOR, BOMB, WALL_CRACKED}
onready var Grid = get_parent()
var direction
var is_pushable = false
var is_player = false
var is_breakable = false
var can_be_player = false
var type
var world_pos
var exist = true
var prev_positions = []

func is_pushable() -> bool:
	return is_pushable

func is_breakable() -> bool:
	return is_breakable

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
	if !tile_obj or tile_obj.is_player() or !tile_obj.exist:
		return true
	if tile_obj.type == BOMB:
		return true
	if tile_obj.is_pushable():
		return tile_obj.check_currently_pushable(direction)
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

func add_prev_position():
	prev_positions.append(world_pos)

func back_to_prev_position():
	if prev_positions.size() > 0:
		world_pos = prev_positions[prev_positions.size() - 1]
		prev_positions.remove(prev_positions.size() - 1)
		position = Grid.map_to_world(world_pos) + Grid.cell_size / 2

# function should be overridden if object can move
func move(direction) -> bool:
	return false

func _ready():
	pass