extends TileMap

enum { EMPTY = -1, WALL, BLUE, GREY, BLOCK, KEY, DOOR, BOMB, WALL_CRACKED, ICE, SNOWBALL}
var prev_movement = Vector2(1,0)

var won = false
var paused = false
var menu_instance
var can_move = true

func set_can_move(boolean):
	can_move = boolean

func _ready():
	for tile in get_used_cells():
		var target = get_cellv(tile)
		match target:
			WALL:
				create_scene_instance("res://logic/tiles/wall/wall.tscn", tile)
			DOOR:
				create_scene_instance("res://logic/tiles/door/door.tscn", tile)
			GREY, BLUE:
				var scene_instance = create_scene_instance("res://logic/tiles/player/player.tscn", tile)
				if target == BLUE:
					scene_instance.make_player()
					scene_instance.change_sprite_to_blue()
			BLOCK:
				create_scene_instance("res://logic/tiles/block/block.tscn", tile)
			KEY:
				create_scene_instance("res://logic/tiles/key/key.tscn", tile)
			BOMB:
				create_scene_instance("res://logic/tiles/bomb/bomb.tscn", tile)
			WALL_CRACKED:
				create_scene_instance("res://logic/tiles/wall_cracked/wall_cracked.tscn", tile)
			SNOWBALL:
				create_scene_instance("res://logic/tiles/snowball/snowball.tscn", tile)
	
	for child in get_tile_children():
		if child.is_player():
			child.color_blue()
	for child in get_tile_children():
		if child.is_player():
			child.animate_step()

func get_tile_children():
	var children = []
	for child in get_children():
		if child.get("is_tile"):
			if child.is_tile:
				children.append(child)
	return children

func cancel_pressed():
	if paused:
		paused = false
		remove_child(menu_instance)
	else:
		paused = true
		var menu = load("res://menu/levelMenu/LevelMenu.tscn")
		menu_instance = menu.instance()
		add_child(menu_instance)

func _process(delta):
	if won:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		cancel_pressed()
	if !paused and can_move:
		if Input.is_action_pressed("ui_reset"):
			get_tree().reload_current_scene()
		elif Input.is_action_pressed("ui_prev"):
			self.set_can_move(false)
			for child in get_tile_children():
				child.back_to_prev_position()
				#messy workaround, this should be doable without knowing the animation timing
			var t = Timer.new()
			t.set_wait_time(0.2)
			t.set_one_shot(true)
			self.add_child(t)
			t.start()
			yield(t, "timeout")
			for child in get_tile_children():
				if child.is_player():
					child.change_sprite()
			self.set_can_move(true)
		else:
			var input_direction = get_input_direction()
			if not input_direction:
				return

			start_move(input_direction)

func start_move(input_direction):
	if check_move(input_direction):
		move(input_direction)
		if check_won():
			win()

func win():
	won = true
	for child in get_tile_children():
		if child.is_player():
			child.animate_win()
	set_process(false)
	var t = Timer.new()
	t.set_wait_time(2)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()

	yield(t, "timeout")
	
	t.queue_free()

	var level = get_parent().get_level()
	global.level_beaten(level)
	get_tree().change_scene("res://worldMap/WorldMap.tscn")

func check_won():
	for child in get_tile_children():
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
	for child in get_tile_children():
		if child.exist and !child.is_possible_move(input_direction):
			return false
	return true

func get_cell_child(position):
	for child in get_tile_children():
		if child.world_pos == position and child.exist and !child.is_background():
			return child

func get_cell_background_child(position):
	for child in get_tile_children():
		if child.world_pos == position and child.exist and child.is_background():
			return child

func activate() -> bool:
	var activated = false
	for child in get_tile_children():
		if child.is_activated():
			child.do_when_activated()
			child.is_activated = false
			activated = true
	return activated

func move_children(input_direction):
	for child in get_tile_children():
		if child.is_player():
			child.move(input_direction)
	for child in get_tile_children():
		if child.is_player():
			child.color_blue()

# Move objects when object is on ice
# It also checks if the target tile is filled with player,
# in which case it should not move!
func move_objects(input_direction):
	var pushed = false
	var children = get_tile_children()
	for child in children:
		if !child.has_moved_in_current_sub_step():
			if !child.is_player():
				#if the object didn't move yet, it will not need to move
				if child.prev_positions[child.prev_positions.size() - 1][0] != child.world_pos:
					if child.is_pushable():
						#check if on ice
						var tile_bg_obj = get_cell_background_child(child.world_pos)
						var target = child.world_pos + input_direction
						var tile_obj = get_cell_child(target)
						if tile_bg_obj != null and tile_bg_obj.type == ICE:
							if !tile_obj or !tile_obj.is_player():
								if child.check_currently_pushable(input_direction):
									child.move(input_direction)
									pushed = true
						#check if snowball
						elif child.type == SNOWBALL:
							if !tile_obj or !tile_obj.is_player():
								if child.check_currently_pushable(input_direction):
									child.move(input_direction)
									pushed = true
	return pushed

func should_move_children_on_ice(input_direction) -> bool:
	var on_ice = false
	for child in get_tile_children():
		if child.is_player():
			var tile_bg_obj = get_cell_background_child(child.world_pos)
			if tile_bg_obj and tile_bg_obj.type == ICE:
				if child.is_possible_move(input_direction):
					on_ice = true

	if on_ice:
		for child in get_tile_children():
			if child.is_player():
				if !child.is_possible_move(input_direction):
					return false
		return true
	else:
		return false

func update_player_sprites():
	for child in get_tile_children():
		if child.is_player():
			child.change_sprite()

func move(input_direction):
	for child in get_tile_children():
		child.add_prev_position()
	move_children(input_direction)
	for child in get_tile_children():
		child.add_animation()

	var steps = 0
	var cont = true
	while cont:
		steps = steps + 1
		var objects_moved = move_objects(input_direction)
		var player_moved = should_move_children_on_ice(input_direction)
		if player_moved:
			move_children(input_direction)
		cont = player_moved or objects_moved
		for child in get_tile_children():
			child.add_animation()

	for child in get_tile_children():
		var prev = child.prev_positions[child.prev_positions.size() - 1][0]
		var curr = child.world_pos

	self.set_can_move(false)
	for i in range(steps):
		for child in get_tile_children():
			child.animate_step()

		#messy workaround, this should be doable without knowing the animation timing
		var t = Timer.new()
		t.set_wait_time(0.2)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")

	self.set_can_move(true)

	for child in get_tile_children():
		child.empty_animation_queue()

	update_player_sprites()

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
