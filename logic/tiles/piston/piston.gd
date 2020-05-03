extends "res://logic/tiles/basicTiles/baseTile.gd"

var direction_facing = Vector2(1,0)

func _ready():
	type = global.Tiles.PISTON
	record_last_move = false

func extend_piston():
	var Grid = get_parent()
	var pushable = true
	for child in Grid.get_cell_child(world_pos + direction_facing):
		if child.is_player():
			pushable = false
		elif child.check_currently_pushable(direction_facing, false):
			child.move_direction = direction_facing
			child.move(direction_facing)
		else:
			pushable = false
	if pushable:
		is_activated = true
		$Sprite.frame = 1

func set_sprite(extend):
	if extend:
		$Sprite.frame = 1
	else:
		$Sprite.frame = 0

func rotate(direction):
	direction_facing = direction
	$Sprite.rotation = direction.angle()
	$Sprite.position += direction * 32

func retract_piston():
	is_activated = false
	$Sprite.frame = 0
