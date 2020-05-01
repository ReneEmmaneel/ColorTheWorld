extends Node

enum Tiles { EMPTY = -1, WALL, BLUE, GREY, BLOCK, KEY, DOOR, BOMB, WALL_CRACKED, ICE, SNOWBALL, PRESSURE_PLATE, ELEC_GATE, PISTON}

var levels_beaten = []
var last_level = 0

var animation_speed = 0.15

var debug_show_all_levels = true
var debug_start_muted = true
var debug_shorcuts = true

var all_level_scenes = []

var worldmap_level_save = []

func save_worldmap_level():
	worldmap_level_save = []
	var WorldMap = get_tree().get_root().get_node("WorldMap")
	if WorldMap:
		for tile in WorldMap.get_node("WorldLevel").get_node("TileMap").get_tile_children():
			worldmap_level_save.append([tile.type, tile.world_pos, tile.make_save()])

func save():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)

	var dict = {
		beaten = levels_beaten,
		worldmap = var2str(worldmap_level_save)
	}

	save_game.store_line(to_json(dict))

	save_game.close()



func load():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.
	save_game.open("user://savegame.save", File.READ)

	var json_result = JSON.parse(save_game.get_as_text()).result

	levels_beaten = json_result["beaten"] if json_result.has("beaten") else []
	if json_result.has("worldmap") and json_result["worldmap"] != null:
		worldmap_level_save = str2var(json_result["worldmap"])

	save_game.close()

func _ready():
	all_level_scenes = level_scenes_to_list("res://levels/")

func get_screen_size():
	return get_viewport().size

func level_beaten(level):
	last_level = level
	if !(level in levels_beaten):
		levels_beaten.append(level)

func level_not_beaten(level):
	last_level = level

func _process(delta):
	if debug_shorcuts:
		if Input.is_action_just_pressed("ui_exit_game"):
			global.quit_game()
		if Input.is_action_just_pressed("debug_next_level"):
			var tm = get_tree().get_root().get_child(2).get_node("TileMap")
			if tm:
				tm.win()

func quit_game():
	save()
	get_tree().quit()

func level_scenes_to_list(path):
	var levels = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	#Open all levels in res://levels and res://levels/World*
	while true:
		var file = dir.get_next()

		if file == "":
			break
		else:
			if !file.begins_with("."):
				if file.begins_with("World"):
					var world_dir = Directory.new()
					var world_path = path + file + "/"
					world_dir.open(world_path)
					world_dir.list_dir_begin()
					while true:
						var file_level = world_dir.get_next()

						if file_level == "":
							break
						else:
							if !file_level.begins_with("."):
								if file_level.ends_with(".tscn"):
									var full_file_name = world_path + file_level
									var level = load(full_file_name)
									if level:
										var level_id = level.instance().level_id
										levels.append([level_id, full_file_name])
					world_dir.list_dir_end()
				elif file.ends_with(".tscn"):
					var full_file_name = path + file
					var level = load(full_file_name)
					if level:
						var level_id = level.instance().level_id
						levels.append([level_id, full_file_name])

	dir.list_dir_end()

	return levels

func get_level_scene(level_id_to_load):
	for level in all_level_scenes:
		var level_id = level[0]
		if level_id == level_id_to_load:
			return level[1]
