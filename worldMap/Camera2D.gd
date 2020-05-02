extends Camera2D

var player_to_follow

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if player_to_follow:
		position = player_to_follow.world_pos * 64 + player_to_follow.get_node("Pivot").position

func set_player_to_follow(tile):
	player_to_follow = tile
