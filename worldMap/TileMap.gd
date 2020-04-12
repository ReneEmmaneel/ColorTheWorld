extends TileMap

var prev_movement = Vector2()
var Player
var Worlds
var player_world_pos

var tiles_to_show = []

enum { EMPTY = -1, START = 60}

func _ready():
	Player = $"../Player"
	Worlds = $"../Worlds"
	
	for tile in get_used_cells():
		var target = get_cellv(tile)
		if (global.last_level == 0 and target == START) or (target + 1 + Worlds.get_world(tile) * 10 == global.last_level):
			player_world_pos = tile
			Player.position = map_to_world(tile) + cell_size / 2
		if target == START:
			if !global.debug_show_all_levels:
				show_tiles(tile)
	for tile in get_used_cells():
		var target = get_cellv(tile)
		if !(tile in tiles_to_show) and !global.debug_show_all_levels:
			set_cellv(tile, EMPTY)
		elif ((target >= 0) and (target <= 9) and ((target + 1 + Worlds.get_world(tile) * 10) in global.levels_beaten)):
			set_cellv(tile, target + 10 * (Worlds.get_world(tile) + 1))

func show_tiles(tile):
	for direction in [Vector2(1,0), Vector2(0,1), Vector2(-1,0), Vector2(0,-1)]:
		var target = tile + direction
		if !(target in tiles_to_show) and get_cellv(target) != EMPTY:
			tiles_to_show.append(target)
			if get_cellv(target) >= 0 and get_cellv(target) <= 9:
				if (get_cellv(target) + 1 + Worlds.get_world(target) * 10) in global.levels_beaten:
					show_tiles(target)
			else:
				show_tiles(target)

func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		var tile = get_cellv(player_world_pos)
		if tile >= 10 and tile <= 39:
			load_level(tile - 9)
		if tile >= 0 and tile <= 9:
			load_level((tile + 1) + Worlds.get_world(player_world_pos) * 10)
	var input_direction = get_input_direction()
	if input_direction:
		move_player(input_direction)

func load_level(level):
	get_tree().change_scene("res://levels/level" + str(level) + "/Level" + str(level) + ".tscn")

func move_player(input_direction):
	if get_cellv(player_world_pos + input_direction) == EMPTY:
		return
	player_world_pos += input_direction
	
	Player.position = map_to_world(player_world_pos) + cell_size / 2
	set_process(false)

	var AnimationPlayer = $"../Player/AnimationPlayer"
	var Tween = $"../Player/Tween"
	var Pivot = $"../Player/Pivot"
	AnimationPlayer.play("Walk")
	Pivot.position = -input_direction * 64
	Tween.interpolate_property(Pivot, "position", -input_direction * 64, Vector2(), AnimationPlayer.current_animation_length, Tween.TRANS_LINEAR, Tween.EASE_IN)
	Tween.start()
	Player.position = map_to_world(player_world_pos) + cell_size / 2
	yield(AnimationPlayer, "animation_finished")
	set_process(true)

func get_input_direction():
	var curr_movement = Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)
	if curr_movement.length() > 1:
		if prev_movement.length() == 1:
			curr_movement = prev_movement
		else:
			curr_movement.y = 0
	
	prev_movement = curr_movement
	return curr_movement