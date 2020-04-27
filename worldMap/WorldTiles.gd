extends TileMap

var prev_movement = Vector2()
var Worlds

var player_world_pos

export (int) var camera_width
export (int) var camera_height
var camera_pos = Vector2(0, 0)

var tiles_to_show = []

#Because TileMaps suck, the id of START can't be changed
enum { EMPTY = -1, START = 24}

func get_level(coor):
	pass

func _ready():
	Worlds = $"../Worlds"

	resize_camera()

	for tile in get_used_cells():
		var target = get_cellv(tile)
		var level = get_level_id(tile)

		#Start unveiling all playable levels starting at the START tile
		if target == START:
			if !global.debug_show_all_levels:
				show_tiles(tile) #should always call in non-debug mode

	#this changes the tiles if level is beaten
	for tile in get_used_cells():
		var target = get_cellv(tile)
		if !(tile in tiles_to_show) and !global.debug_show_all_levels:
			set_cellv(tile, EMPTY)
		elif ((target >= 0) and (target <= 19)):
			var level = get_level_id(tile)
			if !(level in global.levels_beaten):
				$"../UnbeatenLevel".set_cellv(tile, 0)

	Worlds.remove_unused_world_tiles()


func get_level_id(tile):
	var target = get_cellv(tile)
	var world = $"../Worlds".get_world(tile)
	if world >= 0:
		return 1 + target + world * 20
	else:
		return -1

#Starting at START, will
func show_tiles(tile):
	for direction in [Vector2(1,0), Vector2(0,1), Vector2(-1,0), Vector2(0,-1)]:
		var target = tile + direction
		if !(target in tiles_to_show) and get_cellv(target) != EMPTY:
			tiles_to_show.append(target)
			var level = get_level_id(target)
			#level tiles
			if get_cellv(target) >= 0 and get_cellv(target) <= 19:
				if level in global.levels_beaten:
					show_tiles(target)
			#all other tiles are a-OK
			else:
				show_tiles(target)

func _process(delta):
	if !get_parent().is_paused():
		if Input.is_action_pressed("ui_accept"):
			var tiles = get_parent().get_node("WorldLevel").get_node("TileMap").get_tile_children()
			for tile in tiles:
				if tile.is_player:
					var level_tile = get_cellv(tile.world_pos)
					if level_tile >= 0 and level_tile <= 19:
						var level = get_level_id(tile.world_pos)
						load_level(level)

func load_level(level):
	set_process(false)
	global.save_worldmap_level()
	var level_scene_path = global.get_level_scene(level)
	if level_scene_path:
		var Fade = $"../Fade"
		Fade.play("FadeOut")
		yield(Fade, "animation_finished")
		get_tree().change_scene(level_scene_path)

func resize_camera():
	var Camera = $"../Camera2D"
	var screen_size = global.get_screen_size()
	Camera.zoom = Vector2(camera_width * 64, camera_height * 64) / screen_size

#When the player moves out of the camera,
#the camera moves with the given offset
func move_camera(direction):
	camera_pos += direction
	var Camera = $"../Camera2D"
	var offset = Camera.get_offset()
	offset += direction * Vector2(64 * camera_width, 64 * camera_height)
	Camera.set_offset(offset)

func check_camera_pos():
	var done = false
	while !done:
		done = true
		var tiles = get_parent().get_node("WorldLevel").get_node("TileMap").get_tile_children()
		for tile in tiles:
			if tile.is_player: #todo: what if multiple is_player?
				player_world_pos = tile.world_pos
				if (player_world_pos[0] < camera_pos[0] * camera_width):
					move_camera(Vector2(-1,0))
					done = false
				elif (player_world_pos[0] > (camera_pos[0] + 1) * camera_width - 1):
					move_camera(Vector2(1,0))
					done = false

				if (player_world_pos[1] < camera_pos[1] * camera_height):
					move_camera(Vector2(0,-1))
					done = false
				elif (player_world_pos[1] > (camera_pos[1] + 1) * camera_height - 1):
					move_camera(Vector2(0,1))
					done = false

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
