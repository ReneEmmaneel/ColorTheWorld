extends "res://logic/tiles/basicTiles/baseTile.gd"

func _ready():
	open = false
	can_move_onto = true
	type = global.Tiles.ELEC_GATE
	open_gate()
	record_last_move = true

func open_gate():
	for child in $"..".get_cell_child(world_pos):
		if child != self:
			if !child.is_background:
				return
	$Sprite.play("closed")
	open = false

func close_gate():
	$Sprite.play("open")
	open = true

func set_sprite(open):
	if open:
		$Sprite.play("open")
	else:
		$Sprite.play("closed")

func custom_can_get_pushed_into(tile_obj, direction) -> bool:
	return open


func _on_Sprite_animation_finished():
	#do smth with checking which frame the current animation is on, to make sure
	#the animation goes nicely or things
	pass # Replace with function body.
