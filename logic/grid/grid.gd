extends TileMap

enum { EMPTY = -1, WALL, BLUE, GREY, BLOCK, KEY, DOOR, BOMB, WALL_CRACKED}
var prev_movement = Vector2(1,0)

var won = false

func _ready():
	for tile in get_used_cells():
		var target = get_cellv(tile)
		match target:
			WALL:
				var scene_instance = create_scene_instance("res://logic/tiles/wall/wall.tscn", tile)
			DOOR:
				var scene_instance = create_scene_instance("res://logic/tiles/door/door.tscn", tile)
			GREY, BLUE:
				var scene_instance = create_scene_instance("res://logic/tiles/player/player.tscn", tile)
				if target == BLUE:
					scene_instance.make_player()
			BLOCK:
				var scene_instance = create_scene_instance("res://logic/tiles/block/block.tscn", tile)
			KEY:
				var scene_instance = create_scene_instance("res://logic/tiles/key/key.tscn", tile)
			BOMB:
				var scene_instance = create_scene_instance("res://logic/tiles/bomb/bomb.tscn", tile)
			WALL_CRACKED:
				var scene_instance = create_scene_instance("res://logic/tiles/wall_cracked/wall_cracked.tscn", tile)
	
	for child in get_children():
		if child.is_player():
			child.color_blue()

func _process(delta):
	if won:
		return
	if Input.is_action_pressed("ui_cancel"):
		var level = get_parent().get_level()
		global.level_not_beaten(level)
		get_tree().change_scene("res://worldMap/WorldMap.tscn")
	if Input.is_action_pressed("ui_reset"):
		get_tree().reload_current_scene()
	elif Input.is_action_pressed("ui_prev"):
		for child in get_children():
			child.back_to_prev_position()
	else:
		var input_direction = get_input_direction()
		if not input_direction:
			return
	
		if check_move(input_direction):
			move(input_direction)
			if check_won():
				won = true
				for child in get_children():
					if child.is_player():
						child.animate_win()

				set_process(false)
				var t = Timer.new()
				t.set_wait_time(1)
				t.set_one_shot(true)
				self.add_child(t)
				t.start()
			
				yield(t, "timeout")

				var level = get_parent().get_level()
				global.level_beaten(level)
				get_tree().change_scene("res://worldMap/WorldMap.tscn")

func check_won():
	for child in get_children():
		if child.can_be_player() and !child.is_player():
			return false
	return true

func create_scene_instance(path, tile):
	set_cellv(tile, EMPTY)
	var scene = load(path)
	var scene_instance = scene.instance()
	add_child(scene_instance)
	scene_instance.position = map_to_world(tile) + cell_size / 2
	scene_instance.world_pos = tile
	return scene_instance

func check_move(input_direction) -> bool:
	for child in get_children():
		if child.exist and !child.is_possible_move(input_direction):
			return false
	return true

func get_cell_child(position):
	for child in get_children():
		if child.world_pos == position and child.exist:
			return child

func move(input_direction):
	for child in get_children():
		child.add_prev_position()
	
	for child in get_children():
		if child.is_player():
			child.move(input_direction)
	for child in get_children():
		if child.is_player():
			child.color_blue()

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