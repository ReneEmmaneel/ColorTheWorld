extends Control

func _ready():
	$Menu/Buttons/VBoxContainer/StartGameButton.grab_focus()
	for button in $Menu/Buttons/VBoxContainer.get_children():
		button.connect("pressed", self, "_on_button_pressed", [button.scene_to_load])


func _on_button_pressed(scene_to_load):
	get_tree().change_scene(scene_to_load)
