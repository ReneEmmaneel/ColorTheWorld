extends "res://logic/tiles/basicTiles/baseTile.gd"

var open = false

func _ready():
	is_background = true
	type = global.Tiles.ELEC_GATE

func open_gate():
	$Sprite.play("closed")
	open = false

func close_gate():
	$Sprite.play("open")
	open = true

func set_sprite(open):
	print(open)
	if open:
		$Sprite.play("open")
	else:
		$Sprite.play("closed")
