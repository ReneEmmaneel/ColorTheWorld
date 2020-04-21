# baseTile.gd
#
# The parent script for all tiles.
# It has helper functions for getting various attributes of the tile
# It has a fuction that checks if the tile is currently pushable or moveable
# It also has functions which handle the redo functionality

extends Node2D

enum { EMPTY = -1, WALL, BLUE, GREY, BLOCK, KEY, DOOR, BOMB, WALL_CRACKED, ICE, SNOWBALL, PRESSURE_PLATE}
onready var Grid = get_parent()
var direction
var is_tile = true
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

	if check_outside_map(target):
		return false

	if tile_obj and tile_obj.is_player():
		return true
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

func check_outside_map(target) -> bool:
	var Level = $"../.."
	return Level.check_outside_map(target)

func is_possible_move(direction):
	var target = world_pos + direction
	if is_player():
		if check_outside_map(target):
			return false
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
	add_hide_animation()

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
		animate_movement(world_pos, prev_positions[prev_positions.size() - 1][0], false)
		world_pos = prev_positions[prev_positions.size() - 1][0]
		prev_positions.remove(prev_positions.size() - 1)

####animations
var animation_queue = []

func add_to_queue(variable):
	animation_queue.append(variable)

func get_and_remove_first_from_queue():
	var return_value = null
	if animation_queue.size() > 0:
		return_value = animation_queue[0]
		animation_queue.remove(0)
	return return_value

func get_last_from_queue():
	if animation_queue.size() > 0:
		return animation_queue[animation_queue.size() - 1]
	else:
		return null

func empty_animation_queue():
	animation_queue = []

enum {STOP, MOVE, HIDE, BECOME_PLAYER}

#Animation should 
class Anim:
	var type
	var old_pos
	var new_pos
	var instant_anim = false #If true, the animation resolves instantly

	func _init(type, values = [], instant_anim = false):
		self.type = type
		if values.size() > 0:
			self.old_pos = values[0]
			if values.size() > 1:
				self.new_pos = values[1]
			else:
				self.new_pos = self.old_pos
		self.instant_anim = instant_anim

func add_wait_animation(new_pos):
	add_to_queue(Anim.new(STOP, [new_pos]))

func add_move_animation(prev_pos, new_pos):
	add_to_queue(Anim.new(MOVE, [prev_pos, new_pos]))

func add_hide_animation():
	add_to_queue(Anim.new(HIDE, [null, null], true))

func add_become_player_animation():
	add_to_queue(Anim.new(BECOME_PLAYER, [world_pos, world_pos], true))

func add_animation():
	var prev_pos
	if animation_queue.size() > 0:
		prev_pos = animation_queue[animation_queue.size() - 1].new_pos
	else:
		prev_pos = prev_positions[prev_positions.size() - 1][0]
	var new_pos = world_pos
	if prev_pos == new_pos:
		add_wait_animation(new_pos)
	else:
		add_move_animation(prev_pos, new_pos)

func has_moved_in_current_sub_step():
	return world_pos != get_last_from_queue().new_pos

func animate_step():
	var animation_step = get_and_remove_first_from_queue()
	if !animation_step:
		return

	while animation_step != null and animation_step.instant_anim:
		if animation_step.type == HIDE:
			get_sprite().hide()
		elif animation_step.type == BECOME_PLAYER:
			self.change_sprite_to_blue()
		animation_step = get_and_remove_first_from_queue()

	if animation_step != null:
		var prev_pos = animation_step.old_pos
		var new_pos = animation_step.new_pos
		if prev_pos != null and new_pos != null:
			animate_movement(prev_pos, new_pos, false)

func change_sprite_to_blue():
	pass

# function should be overridden if object can move
func animate_movement(prev, curr, hide):
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
