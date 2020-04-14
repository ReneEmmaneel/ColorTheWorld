extends TileMap

enum { EMPTY = -1, WALL, BLUE, GREY, BLOCK, KEY, DOOR, BOMB, WALL_CRACKED, ICE}

var TileMap

func _ready():
	TileMap = get_node("../TileMap")

	for tile in get_used_cells():
		var target = get_cellv(tile)
		match target:
			ICE:
				var scene_instance = create_scene_instance(TileMap, "res://logic/tiles/ice/ice.tscn", tile)

func create_scene_instance(tilemap, path, tile):
	set_cellv(tile, EMPTY)
	var scene = load(path)
	var scene_instance = scene.instance()
	tilemap.add_child(scene_instance)
	scene_instance.position = map_to_world(tile) + cell_size / 2
	scene_instance.world_pos = tile
	scene_instance.is_background = true
	return scene_instance