extends TileMap

var prev_movement = Vector2()
var Player
var Worlds
var player_world_pos

export (int) var camera_width
export (int) var camera_height
var camera_pos = Vector2(0, 0)

var tiles_to_show = []

#Because TileMaps suck, the id of START can't be changed
enum { EMPTY = -1, START = 60}

func get_level(coor):
	pass

func _ready():
	Player = $"../Player"
	Worlds = $"../Worlds"

	resize_camera()
	
	for tile in get_used_cells():
		var target = get_cellv(tile)
		var level = target + 1 + Worlds.get_world(tile) * 10

		#Put player on the right tile
		if (global.last_level == 0 and target == START) or (level == global.last_level):
			player_world_pos = tile
			Player.position = map_to_world(tile) + cell_size / 2
			check_camera_pos()

		#Start unveiling all playable levels starting at the START tile
		if target == START:
			if !global.debug_show_all_levels:
				show_tiles(tile) #should always call in non-debug mode

	#this changes the tiles if level is beaten
	for tile in get_used_cells():
		var target = get_cellv(tile)
		if !(tile in tiles_to_show) and !global.debug_show_all_levels:
			set_cellv(tile, EMPTY)
		elif ((target >= 0) and (target <= 9)):
			var level = target + 1 + Worlds.get_world(tile) * 10
			if !(level in global.levels_beaten):
				$"../UnbeatenLevel".set_cellv(tile, 0)

	Worlds.remove_unused_world_tiles()

#Starting at START, will 
func show_tiles(tile):
	for direction in [Vector2(1,0), Vector2(0,1), Vector2(-1,0), Vector2(0,-1)]:
		var target = tile + direction
		if !(target in tiles_to_show) and get_cellv(target) != EMPTY:
			tiles_to_show.append(target)
			var level = get_cellv(target) + 1 + Worlds.get_world(target) * 10
			#level tiles
			if get_cellv(target) >= 0 and get_cellv(target) <= 9:
				if level in global.levels_beaten:
					show_tiles(target)
			#all other tiles are a-OK
			else:
				show_tiles(target)

func _process(delta):
	if !get_parent().is_paused():
		if Input.is_action_pressed("ui_accept"):
			var tile = get_cellv(player_world_pos)
			if tile >= 0 and tile <= 9:
				var level = 1 + tile + Worlds.get_world(player_world_pos) * 10
				load_level(level)
		var input_direction = get_input_direction()
		if input_direction:
			move_player(input_direction)

func load_level(level):
	var Fade = $"../Fade"
	var level_scene_path = "res://levels/Level" + str(level) + ".tscn"
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
	#x pos starts at 1, while y pos starts at 0
	var done = false
	while !done:
		done = true
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

func move_player(input_direction):
	if get_cellv(player_world_pos + input_direction) == EMPTY:
		return
	player_world_pos += input_direction
	
	Player.position = map_to_world(player_world_pos) + cell_size / 2
	set_process(false)
	
	check_camera_pos()
	
	var AnimationPlayer = $"../Player/AnimationPlayer"
	var Tween = $"../Player/Tween"
	var Pivot = $"../Player/Pivot"
	AnimationPlayer.play("Walk")
	Pivot.position = -input_direction * 64
	Tween.interpolate_property(Pivot, "position", -input_direction * 64, Vector2(), global.animation_speed, Tween.TRANS_LINEAR, Tween.EASE_IN)
	Tween.start()
	Player.position = map_to_world(player_world_pos) + cell_size / 2
	yield(Tween, "tween_completed")
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
