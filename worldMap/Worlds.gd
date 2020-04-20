extends TileMap

func _ready():
	pass

func get_world(tile):
	return get_cellv(tile) - 1

func set_world(tile, world):
	set_cellv(tile, world)
