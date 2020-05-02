extends Node2D

func _ready():
	var Camera = get_parent().get_parent().get_node("Camera2D")
	var screen_size = global.get_screen_size()
	position = - (screen_size * Camera.zoom) / 2 + Camera.position
	$Pos.rect_size = screen_size * Camera.zoom

	$Pos/Menu/ContinueLevelButton.grab_focus()
	for button in $Pos/Menu.get_children():
		button.connect("pressed", self, "_on_button_pressed", [button.scene_to_load, button.save_level, button])


func _on_button_pressed(scene_to_load, save_level, button):
	if $Pos/Menu/ContinueLevelButton and button == $Pos/Menu/ContinueLevelButton:
		get_parent().cancel_pressed()

	if save_level:
		var level = get_parent().get_parent().get_level()
		global.level_not_beaten(level)
	if scene_to_load != "":
		get_tree().change_scene(scene_to_load)
