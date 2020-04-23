extends TileMap

enum { EMPTY = -1, WALL, BLUE, GREY, BLOCK, KEY, DOOR, BOMB, WALL_CRACKED, ICE, SNOWBALL, PRESSURE_PLATE, ELEC_GATE}
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
			global.Tiles.ELEC_GATE:
				create_scene_instance("res://logic/tiles/elec_gate/elec_gate.tscn", tile)

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

func _process(_delta):
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

			for wire_sprite in update_wires()[0]:
				wire_sprite[0].set_sprites(wire_sprite[1])

			var t = Timer.new()
			t.set_wait_time(global.animation_speed)
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
	var children = []
	for child in get_tile_children():
		if child.world_pos == position and child.exist and !child.is_background():
			children.append(child)
	return children

func get_cell_background_child(position):
	var Background = $"../BackLayer"
	if Background.get_cellv(position) == ICE:
		return ICE

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
				if child.record_last_move:
					var last_substep_pos = child.get_last_from_queue().old_pos
					#if the object didn't move yet, it will not need to move
					if last_substep_pos != child.world_pos:
						if child.is_pushable():
							#check if on ice
							var tile_bg_obj_type = get_cell_background_child(child.world_pos)
							var target = child.world_pos + input_direction
							if tile_bg_obj_type == ICE:
								if child.check_currently_pushable(input_direction):
									child.move(input_direction)
									pushed = true

							#check if snowball
							elif child.type == SNOWBALL:
								if child.check_currently_pushable(input_direction):
									child.move(input_direction)
									pushed = true
	return pushed

func should_move_children_on_ice(input_direction) -> bool:
	var on_ice = false
	for child in get_tile_children():
		if child.is_player():
			var tile_bg_obj_type = get_cell_background_child(child.world_pos)
			if tile_bg_obj_type == ICE:
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

func activate_wires_recursive(tile, Wire):
	if Wire.get_cellv(tile) == -1:
		return
	for dir in [Vector2(1,0), Vector2(0,1), Vector2(-1, 0), Vector2(0, -1)]:
		var target = tile + dir
		if Wire.get_cellv(target) == Wire.WIRE_OFF:
			Wire.set_cellv(target, Wire.WIRE_ON)
			Wire.update_bitmask_area(target)
			activate_wires_recursive(target, Wire)

	for cell in get_children():
		if cell && cell.get("type") && cell.type == global.Tiles.ELEC_GATE:
			if cell.world_pos == tile:
				cell.close_gate()

func get_wire_scenes():
	var Parent = $".."
	var wire_list = []
	var i = 1
	while Parent.has_node("Wire" + str(i)):
		wire_list.append(Parent.get_node("Wire" + str(i)))
		i += 1
	return wire_list
	print(wire_list)

#Update the wires in the current substep
#Returns a list of the following lists, in the following order:
#	A list of all wire tiles and their corresponding sprites in the wire layer
#	A list of all elec gate child objs and their corresponding open status
func update_wires():
	var wire_scenes = get_wire_scenes()
	var BackLayer = $"../BackLayer"

	for child in get_tile_children():
		if child.type == ELEC_GATE:
			child.open_gate()

	var wire_sprites = []
	for Wire in wire_scenes:
		var curr_wire_sprites = []
		Wire.deactivate_wires()

		for child in get_tile_children():
			var tile = child.world_pos
			var bgtile = BackLayer.get_cellv(tile)
			if bgtile == PRESSURE_PLATE:
				activate_wires_recursive(tile, Wire)

		for wire in Wire.get_used_cells():
			curr_wire_sprites.append([wire, Wire.get_cellv(wire)])

		wire_sprites.append([Wire, curr_wire_sprites])

	var elec_gates_status = []
	for child in get_children():
		if child && child.get("type") && child.type == global.Tiles.ELEC_GATE:
			elec_gates_status.append([child, child.open])

	return [wire_sprites, elec_gates_status]

func move(input_direction):
	for child in get_tile_children():
		child.add_prev_position()
	move_children(input_direction)
	for child in get_tile_children():
		child.add_animation()

	var wires_sprites = []
	var elec_gate_sprites = []
	var elec_sprite = update_wires()
	wires_sprites.append(elec_sprite[0])
	elec_gate_sprites.append(elec_sprite[1])

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
		elec_sprite = update_wires()
		wires_sprites.append(elec_sprite[0])
		elec_gate_sprites.append(elec_sprite[1])

	for child in get_tile_children():
		if child.record_last_move:
			var prev = child.prev_positions[child.prev_positions.size() - 1][0]
			var curr = child.world_pos

	self.set_can_move(false)

	for i in range(steps):
		for child in get_tile_children():
			child.animate_step()

		for wire_sprite in wires_sprites[i]:
			wire_sprite[0].set_sprites(wire_sprite[1])

		for elec_gate in elec_gate_sprites[i]:
			elec_gate[0].set_sprite(elec_gate[1])

		#messy workaround, this should be doable without knowing the animation timing
		var t = Timer.new()
		t.set_wait_time(global.animation_speed)
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
