extends Node2D

func _ready():
	$Pos.rect_size = global.get_screen_size()
	position = $"../Camera2D".position - global.get_screen_size() / 2
	$Pos/Menu/BackToWorldmapButton.grab_focus()
	for button in $Pos/Menu.get_children():
		button.connect("pressed", self, "_on_button_pressed", [button.scene_to_load, button.save_level, button])

func _on_button_pressed(scene_to_load, save_level, button):
	if $Pos/Menu/BackToWorldmapButton and button == $Pos/Menu/BackToWorldmapButton:
		get_parent().get_node("WorldLevel").get_node("TileMap").cancel_pressed()
		get_parent().cancel_pressed()
	if $Pos/Menu/ContinueGameButton and button == $Pos/Menu/ContinueGameButton:
		get_parent().back_to_titlescreen()
	if $Pos/Menu/ResetWorldButton and button == $Pos/Menu/ResetWorldButton:
		global.worldmap_level_save = []
		get_parent().reset_worldmap()

func _process(delta):
	position = $"../Camera2D".position - global.get_screen_size() / 2
