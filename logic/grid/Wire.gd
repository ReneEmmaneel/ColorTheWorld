extends TileMap

enum {EMPTY = -1, WIRE_OFF, WIRE_ON}

func _ready():
	pass # Replace with function body.

func deactivate_wires():
	for tile in get_used_cells():
		if get_cellv(tile) == WIRE_ON:
			set_cellv(tile, WIRE_OFF)
			update_bitmask_area(tile)

# The input should be a 2d list of tile, sprite combos
func set_sprites(sprites):
	for sprite in sprites:
		set_cellv(sprite[0], sprite[1])
		update_bitmask_area(sprite[0])
