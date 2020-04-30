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
var record_last_move = false
var is_tile = true
var is_pushable = false
var is_player = false
var is_breakable = false
var is_background = false
var is_activated = false
var can_move_onto = false
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

# Returns true if the current object can be pushed in the given direction.
# This means that the tile in the given direction is
# empty, the player or a pushable object that's currently pushable.
# It also calls custom_currently_pushable, which is a function that calls
# to see if the current tile can be pushed into the given tile_obj
# Multiple times every substep
#
# If player_has_moved is false, this means that in the current substep the player
# has not moved. This means that when pushed into a player, the player should move.
func check_currently_pushable(direction, player_has_moved = true) -> bool:
	var target = world_pos + direction
	var pushable = true
	if check_outside_map(target):
		return false

	if !self.exist:
		return false

	for tile_obj in Grid.get_cell_child(target):
		if tile_obj == null:
			return false
		if tile_obj and tile_obj.is_player():
			print(player_has_moved)
			if player_has_moved:
				if tile_obj.check_currently_pushable(direction, player_has_moved):
					continue
			else:
				return false
		if custom_currently_pushable(tile_obj, direction):
			continue
		if !tile_obj.custom_can_get_pushed_into(self, direction):
			return false
		if is_breakable() and tile_obj.type == BOMB:
			continue
		if tile_obj.is_pushable():
			if tile_obj.check_currently_pushable(direction, player_has_moved):
				continue
		if tile_obj.can_move_onto:
			continue
		return false
	return true

# Check if the player is able to move in the given direction.
# This will be called once every turn
func is_possible_move(direction):
	var target = world_pos + direction
	var level = get_parent().get_parent()
	if level.is_world_level:
		if is_player():
			var WorldTiles = level.get_parent().get_node("WorldTiles")
			if WorldTiles.get_cellv(target) == -1:
				return

	if is_player():
		if check_outside_map(target):
			return false

		for tile_obj in Grid.get_cell_child(target):
			if tile_obj == null:
				return false
			if !tile_obj.custom_can_get_pushed_into(self, direction):
				return false
			if !tile_obj or tile_obj.is_player() or !tile_obj.exist:
				continue
			elif tile_obj.is_pushable():
				if tile_obj.check_currently_pushable(direction):
					continue
				else:
					return false
			elif tile_obj.can_move_onto:
				continue
			else:
				return false
	return true

func custom_currently_pushable(tile_obj, direction) -> bool:
	return false

func custom_can_get_pushed_into(tile_obj, direction) -> bool:
	return true

func check_outside_map(target) -> bool:
	var Level = $"../.."
	return Level.check_outside_map(target)

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

var open = false

func add_prev_position():
	if record_last_move:
		prev_positions.append([world_pos, exist, open])

func back_to_prev_position():
	if record_last_move:
		if prev_positions.size() > 0:
			var prev = prev_positions[prev_positions.size() - 1]
			if exist != prev[1]:
				if exist:
					remove_obj()
				else:
					readd_obj()
			if open != prev[2]:
				open = prev[2]
				set_sprite(prev[2])

			animate_movement(world_pos, prev[0], false)
			world_pos = prev[0]
			prev_positions.remove(prev_positions.size() - 1)

#Just a stump function, currently only overridden in elec_gate
func set_sprite(open):
	pass

####animations
var animation_queue = []

func length_animation_queue():
	return animation_queue.size()

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


func empty_and_execute_animation_queue():
	while animation_queue.size() > 0:
		animate_step()

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
	add_to_queue(Anim.new(HIDE, [world_pos, world_pos], true))

func add_become_player_animation():
	add_to_queue(Anim.new(BECOME_PLAYER, [world_pos, world_pos], true))

func add_animation():
	if record_last_move:
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
	if record_last_move:
		return world_pos != get_last_from_queue().new_pos
	else:
		return false

func animate_step():
	if record_last_move:
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

func make_save():
	pass

func create_from_save(data):
	pass

func _ready():
	pass
