extends TileMap

func _ready():
	pass

func get_world(tile):
	return get_cellv(tile) - 1

func set_world(tile, world):
	set_cellv(tile, world)

func remove_unused_world_tiles():
	var WorldTiles = $"../WorldTiles"
	for tile in get_used_cells():
		var target = WorldTiles.get_cellv(tile)
		if !(target >= 0 && target <= 9):
			set_cellv(tile, -1)
