extends Control

func _ready():
	var Buttons = $Menu/Buttons/VBoxContainer
	Buttons.get_node("StartGameButton").grab_focus()
	for button in Buttons.get_children():
		button.connect("pressed", self, "_on_button_pressed", [button.scene_to_load])
	set_size(global.get_screen_size())
	$ColorRect.set_size(global.get_screen_size())

func _on_button_pressed(scene_to_load):
	if scene_to_load != "":
		get_tree().change_scene(scene_to_load)
